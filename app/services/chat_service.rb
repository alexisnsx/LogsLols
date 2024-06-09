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
      stream_response(@response, @prompt)
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
    # Consider refactor using https://github.com/drnic/groq-ruby
    def initialize(prompt:, response:)
      @prompt = prompt
      @response = response
    end

    def call
      stream_response(@response, @prompt)
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
      messages = system_instructions.map do |instruction|
        { role: "system", content: instruction}
      end

      messages << { role: "user", content: prompt}

      stream_tool_response(@response, messages)
    end

    private

    def system_instructions
      [
        "You are a function-calling LLM that knows how to use functions stored in the tools array to get answers for the user."
      ]
    end

    def get_weather(location, unit = 'celsius')
      "Weather is fine!"
    end

    WEATHER_TOOL = {
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


  def stream_tool_response(response, messages)
    sse = SSE.new(response.stream, event: "message")
    begin
      client.chat(
        parameters: {
          model: "llama3-70b-8192",
          messages: [{ role: "user", content: prompt }],
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

  def client
    @_client ||= OpenAI::Client.new(
      access_token: ENV.fetch('GROQ_ACCESS_TOKEN'),
      uri_base: "https://api.groq.com/openai",
      log_errors: true
    )
  end
  end
end
