class GroqchatService
  # Uses Groq ruby gem https://github.com/drnic/groq-ruby
  include ActionController::Live # allows us to stream response based on server-sent events
  include Groq::Helpers

  attr_reader :message

  def initialize(prompt:, response:)
    @prompt = prompt
    @response = response
  end

  class CompletionStream < GroqchatService
    def call
      sse = SSE.new(@response.stream, event: "message")
      messages = [
        S("You are a fabulous administrative assistant who helps the user organise their tasks easily and helps think of ideas and solutions."),
        U(@prompt)
      ]
      metadata = ""
      begin
      mixtral7b_client.chat(messages, stream: ->(chunk, response) {
        unless chunk == nil
          sse.write({ message: chunk })
        else
          metadata = response
        end
      })
      ensure
        sse.close
      end
      pp "--------------The metadata related to the last chat:---------------"
      pp metadata
    end
  end

  class ToolUseStream < GroqchatService
    def call
      messages = [
        S(%q(
          You are a friendly assistant who is provided with tools to find answers for the user. If a tool is relevant, you should incorporate the tool's response in your answer to the user. For example, based on a function call to 'get_weather_report', you receive the information of "35 degrees celsius. So hot". You should then include the specific mention of '35 degrees celsius' in your response to the user. You should never mention the tool. But if there are no relevant tools, answer as yourself.
          )),
        U(@prompt)
      ]

      first_reply = llama70b_client.chat(messages, tools: tools)

      # Catch malformed first_reply i.e. no content and no tool calls e.g.{"role"=>""}, {"role"=>"assistant", "content"=>"<tool-use>{}</tool-use>"}. StandardError triggers RescueStream
      if first_reply.nil? || !first_reply.include?("content" && "tool_calls") || first_reply["content"].include?("<tool-use>")
        raise StandardError
      end

      first_reply = first_reply.symbolize_keys
      pp "--------------This is the first reply:---------------"
      pp first_reply

      # Return first_reply immediately if it has no tool_calls
      return stream_direct(@response, first_reply[:content]) if !first_reply.include?(:tool_calls)

      tool_call_id = first_reply[:tool_calls].first["id"]
      func = first_reply[:tool_calls].first["function"]["name"]
      args = first_reply[:tool_calls].first["function"]["arguments"]
      args = JSON.parse(args).symbolize_keys
      tool_response = ""

      # Correct the LLM if the tool identified does not exist
      if !tools.any? { |tool| tool[:function][:name] == func }
        messages << S("There was no relevant tool. Answer as yourself.")
        pp "---------This is the system note to answer directly:-----------"
        pp messages
        return get_final_response(@response, messages)
      else
        # If tool exists, call it and add to messages for LLM to summarise
        messages << first_reply
        case func
        when "get_weather_report"
          begin
            tool_response = get_weather_report(**args)
            messages << T(tool_response, tool_call_id: tool_call_id, name: func)
            get_final_response(@response, messages)
          rescue => e
            puts "An error occurred: #{e.message}"
            raise StandardError
          end
        end
        pp "------------Tool response:-------------"
        pp tool_response if tool_response
      end
    end
  end


  class RescueStream < GroqchatService
    def initialize(response:)
      @response = response
    end

    def call
      rescue_msg = "Great question! As I am still developing, I may not have understood your question. Could you try rephrasing?"
      stream_direct(@response, rescue_msg)
    end
  end


  private

  def stream_direct(response, reply)
    sse = SSE.new(response.stream, event: "message")
    bits = reply.scan(/.{1,2}/)
    bits.each do |bit|
      sse.write({ message: bit })
    end
   rescue ActionController::Live::ClientDisconnected
    sse.close
   ensure
    sse.close
  end

  def get_final_response(response, messages)
    sse = SSE.new(response.stream, event: "message")
    metadata = ""
    begin
      mixtral7b_client.chat(messages, stream: ->(chunk, response) {
      unless chunk == nil
        sse.write({ message: chunk })
      else
        metadata = response
      end
    })
    ensure
      sse.close
    end
    # pp "--------------The metadata related to the last chat:---------------"
    # pp metadata
  end

  def get_weather_report(city:)
    url = "https://api.openweathermap.org/data/2.5/weather?units=metric&q=#{city}&appid=#{ENV['OPENWEATHER_API_KEY']}"
    response = RestClient.get(url)
    data = JSON.parse(response)
    "Description: #{data["weather"][0]["description"]}, Temperature: #{data["main"]["temp"]}, Feels like: #{data["main"]["feels_like"]}"
  end

  def tools
    get_weather_report_tool = {
      type: "function",
      function: {
        name: "get_weather_report",
        description: "Get the weather report for a city",
        parameters: {
        type: "object",
        properties: {
          city: {
            type: "string",
            description: "The city or region to get the weather report for"
          }
        },
        required: ["city"]
        }
      }
    }
    [ get_weather_report_tool ]
  end

  def models
    @_models = Groq::Model.model_ids
    # => ["llama3-8b-8192", "llama3-70b-8192", "llama2-70b-4096", "mixtral-8x7b-32768", "gemma-7b-it"]
  end

  def client
    @_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"]) do |faraday|
      # Log request and response bodies
      faraday.response :logger, logger, bodies: true
    end
  end

  def mixtral7b_client  # 32K tokens context window
    @_mixtral7b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "mixtral-8x7b-32768")
  end

  # def llama8b_client
  #   @_llama8b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "llama3-8b-8192")
  # end

  def llama70b_client  # 8K tokens context window
    @_llama70b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "llama3-70b-8192")
  end

  def logger
      # Create a logger instance
    @_logger = Logger.new(STDOUT)
    @_logger.level = Logger::DEBUG
  end
end
