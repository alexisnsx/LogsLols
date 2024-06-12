class GroqchatService
  # Uses Groq ruby gem https://github.com/drnic/groq-ruby
  include ActionController::Live # allows us to stream response based on server-sent events

  attr_reader :message

  def initialize(prompt:, response:)
    @prompt = prompt
    @response = response
  end

  class CompletionStream < GroqchatService
    def calling
      llama8b_client.chat("Hello, world!")
    end

    # def call
    #   @client.chat(messages) do |content|
    #     print content
    #   end
    #   puts
    # end

  end

  private
  def stream_response
    @client.chat(messages) do |content|
      print content
    end
    puts
  end

  def models
    @_models = Groq::Model.model_ids
    # => ["llama3-8b-8192", "llama3-70b-8192", "llama2-70b-4096", "mixtral-8x7b-32768", "gemma-7b-it"]
  end

  def llama8b_client
    @_llama8b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "llama3-8b-8192")
  end

  def llama70b_client
    @_llama70b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "llama3-70b-8192")
  end
end
