class ConversationsController < ApplicationController

  def get_weather(location)
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

  # params = {
  #     model: "gpt-3.5-turbo-1106",
  #     name: "My Task Assistant",
  #     description: nil,
  #     instructions: "You are a productivity assistant. When asked a question, provide answers that can help the user fulfill his tasks.",
  #     tools: [ WEATHER_TOOL ],
  #     # "metadata": { my_internal_version_id: "1.0.0" }
  # }

  # my_asst = client.assistants.create(parameters: params)

  def index
    @chat = Chat.find(params[:chat_id])
    @conversation = Conversation.new
    # @response = ChatService::OpenAiCompletion.new(message: "What should I eat for breakfast today?").call
    # @count = OpenAI.rough_token_count(@response)

    # @client = OpenAI::Client.new
    # @assistant_id = ENV.fetch("OPENAI_ASSISTANT_ID")
    # Note to team-mates: You can add raise here and type '@client.assistants.retrieve(assistant_id)' in browser console to see details of the assistant created

  #   response = client.chat(
  #   parameters: {
  #       model: "gpt-3.5-turbo-1106",
  #       messages: [{ role: "user", content: "Tell me a joke!"}],
  #       temperature: 0.7,
  #   })
  #   @message = response.dig("choices", 0, "message", "content")
  #   @count = OpenAI.rough_token_count(@message)
  end
end
