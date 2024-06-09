class ChatService
  include ActionController::Live # allows us to stream response based on server-sent events

  attr_reader :message

  def initialize(prompt:) # i.e. initialise with (message: "something")
    @prompt = prompt
  end

  class OpenAiCompletion < ChatService
    # In rails c, test with "ChatService::OpenAiCompletion.new(prompt: "I need something to cheer me up").call"

    def call
      messages = persona_instructions.map do |instruction|
        { role: "system", content: instruction}
      end

      messages << { role: "user", content: prompt}

      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo-16k", # Can consider swapping to cheaper model
          messages: messages,
          temperature: 0.7,
        })
        response.dig("choices", 0, "message", "content")
    end

    private

    def persona_instructions
      [
        "You are a famous chef that loves to share simple, easy-to-cook recipes."
      ]
    end
  end

  class OpenAiCompletionStream < ChatService
    def call
      sse = SSE.new(response.stream, event: "message")
      begin
        client.chat(
          parameters: {
            model: "gpt-3.5-turbo-16k",
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
  end

  private

  # Set client as instance variable and initialise only once so we can use the same client instance throughout
  def client
    @_client ||= OpenAI::Client.new
  end
end