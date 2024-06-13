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
      first_reply = llama8b_client.chat(messages, tools: tools)
      first_reply = first_reply.symbolize_keys
      pp "--------------This is the first reply:---------------"
      pp first_reply

      return stream_response(@response, messages) if !first_reply.include?(:tool_calls)

      tool_call_id = first_reply[:tool_calls].first["id"]
      func = first_reply[:tool_calls].first["function"]["name"]
      args = first_reply[:tool_calls].first["function"]["arguments"]
      args = JSON.parse(args).symbolize_keys
      tool_response = ""

      if !tools.include?(func)
        # add in new message for the bot to stop using tools
        return stream_response(@response, messages)
      else
        messages << first_reply
        case func
        when "get_weather_report"
          begin
            tool_response = get_weather_report(**args)
            messages << T(tool_response, tool_call_id: tool_call_id, name: func)
            stream_response(@response, messages)
          rescue => e
            puts "An error occurred: #{e.message}"
            stream_response(@response, messages)
          end
        end
      end
    end
  end

  private

  def stream_response(response, messages)
    pp "------------These are the messages used to stream:-------------"
    pp messages
    sse = SSE.new(response.stream, event: "message")
    metadata = ""
    begin
      llama8b_client.chat(messages, stream: ->(chunk, response) {
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

  def get_weather_report(city:)
    url = "https://api.openweathermap.org/data/2.5/weather?units=metric&q=#{city}&appid=#{ENV['OPENWEATHER_API_KEY']}"
    response = RestClient.get(url)
    data = JSON.parse(response)
    tool_response = "Description: #{data["weather"][0]["description"]}, Temperature: #{data["main"]["temp"]}, Feels like: #{data["main"]["feels_like"]}"
    pp "--------------This is the tool's response:---------------"
    pp tool_response
    tool_response
  end

  def tavily_search()
    url = "https://api.tavily.com/search"
    # travily needs the base url as a fetch reponse with the nested requirements in the json body.
    {
      "api_key": "ENV FILE",
      "query": @prompt,
      "search_depth": "basic",
      "include_answer": false,
      "include_images": false,
      "include_raw_content": true,
      "max_results": 3,
      "include_domains": [],
      "exclude_domains": []
    }

  end

  def tools
    [{
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
    }, {
      type: "function",
      function: {
        name: "tavily_search",
        description: "Call this to search on the web and get the relevant information based on the query.",
        parmeters: {
          type: "object",
          properties: {

          }
        }
      }
    }
  ]

  'You are a helpful assistant. Answer all questions to the best of your ability. Use the suite of tools provided if needed. You may not need to use tools for every query - the user may just want to chat!'
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

  def mixtral7b_client
    @_mixtral7b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "mixtral-8x7b-32768")
  end

  def llama8b_client
    @_llama8b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "llama3-8b-8192")
  end

  def llama70b_client
    @_llama70b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "llama3-70b-8192")
  end

  def logger
      # Create a logger instance
    @_logger = Logger.new(STDOUT)
    @_logger.level = Logger::DEBUG
  end
end
