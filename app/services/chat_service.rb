class ChatService
  include ActionController::Live # allows us to stream response based on server-sent events

  attr_reader :message

  def initialize(prompt:) # i.e. initialise with (message: "something")
    @prompt = prompt
  end

  class OpenAiCompletion < ChatService
    # In rails c, test with "ChatService::OpenAiCompletion.new(prompt: "I need something to cheer me up").call"

    def call
      messages = system_instructions.map do |instruction|
        { role: "system", content: instruction}
      end

      messages << { role: "user", content: prompt}

      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo-1106", # Can consider swapping to cheaper model
          messages: messages,
          temperature: 0.7,
        })
      response.dig("choices", 0, "message", "content")
    end

    private

    def system_instructions
      [
        "You are a famous chef that loves to share simple, easy-to-cook recipes."
      ]
    end

    # Set client as instance variable and initialise only once so we can use the same client instance throughout
    def client
      @_client ||= OpenAI::Client.new(
        access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"),
        log_errors: true
      )
    end
  end

  class OpenAiCompletionStream < ChatService
    def initialize(prompt:, response:)
      @prompt = prompt
      @response = response
    end

    def call
      messages = [{ role: "user", content: @prompt}]
      model = "gpt-3.5-turbo-1106"
      stream_response(@response, messages, model)
    end

    private

    def client
      @_client ||= OpenAI::Client.new(
        access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"),
        log_errors: true
      )
    end
  end

  class GroqCompletionStream < ChatService
    def initialize(prompt:, response:)
      @prompt = prompt
      @response = response
    end

    def call
      messages = [{ role: "user", content: @prompt}]
      model = "llama3-70b-8192"
      stream_response(@response, messages, model)
    end

    private

    def client
      @_client ||= OpenAI::Client.new(
        access_token: ENV.fetch('GROQ_ACCESS_TOKEN'),
        uri_base: "https://api.groq.com/openai",
        log_errors: true
      )
    end
  end

  class GroqToolUseStream < ChatService
    def initialize(prompt:, response:)
      @prompt = prompt
      @response = response
    end

    def call
      model = "llama3-70b-8192"
      # messages = system_instructions.map do |instruction|
      #   { role: "system", content: instruction}
      # end
      messages = [{ role: "user", content: @prompt}]
      tools = add_tools
      # 1. Check if the model wanted to call a function
      tool_calls = check_tool_call(messages, tools, model)
      if tool_calls != nil
        # 2. Send the info for the function call
        stream_tool_response(@response, tool_calls, messages, model)
      else
        stream_response(@response, messages, model)
      end
    end

    private
    def check_tool_call(messages, tools, model)
      begin
        ai_response = client.chat(
          parameters: {
            model: model,
            messages: messages,
            tools: tools,
            # tool_choice: 'auto',
          }
        )
      rescue StandardError => e
        puts "#{e.message}"
        return nil
      else
        response_message = ai_response.dig("choices", 0, "message")
        response_message.dig("tool_calls")
      end
    end

    def stream_tool_response(response, tool_calls, messages, model)
      func_name = tool_calls.dig(0, "function", "name")
      arguments = JSON.parse(tool_calls.dig(0, "function", "arguments"), { symbolize_names: true }, # convert JSON object keys into Ruby symbols instead of strings
      )
      # 3. Call the function
      case func_name
      when "get_weather"
        func_response = get_weather(**arguments) # ** converts the hash into individual keyword arguments
      end

      messages.append(
        {
          role: "function",
          tool_call_id: tool_calls.dig(0, 'id'),
          name: func_name,
          content: func_response
        }
      )
      # stream_response(@response, messages, model)

      final_response = client.chat(
        parameters: {
          model: model,
          messages: messages,
          stream: true
        })
        final_response.dig("choices", 0, "message", "content")
        debugger
    end

    def client
      @_client ||= OpenAI::Client.new(
        access_token: ENV.fetch('GROQ_ACCESS_TOKEN'),
        uri_base: "https://api.groq.com/openai",
        log_errors: true
      )
    end

    def system_instructions
      [
        "You are a savvy LLM that sometimes uses functions to get answers for the user. If the functions are not relevant, simply answer directly."
      ]
    end

    def get_weather(location:, unit: 'celsius')
      "Weather is fine!"
    end

    def add_tools
      weather_tool = {
        type: "function",
        function: {
          name: "get_weather",
          description: "Get the current weather in a given location",
          parameters: {
            type: :object,
            properties: {
              location: {
                type: :string,
                description: "The city and state, e.g. San Francisco, CA",
              },
              unit: {
                type: "string",
                enum: %w[celsius fahrenheit],
              },
            },
            required: ["location"],
          },
        },
      }
      [ weather_tool ]
    end
  end

  private

  def stream_response(response, messages, model)
    sse = SSE.new(response.stream, event: "message")
    begin
      client.chat(
        parameters: {
          model: model,
          messages: messages,
          stream: proc do |chunk|
            content = chunk.dig('choices', 0, 'delta', 'content')
            return if content.nil?
            sse.write({ message: content })
          end
        }
      )
    ensure
      sse.close
    end
  end
end
