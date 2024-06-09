class ConversationResponsesController < ApplicationController
  include ActionController::Live # allows us to stream response based on server-sent events

  def index
    response.headers['Content-Type'] = "text/event-stream"
    response.headers['Last-Modified'] = Time.now.httpdate
    prompt = params[:prompt]

    # Change this service whenever another is needed
    # Need to pass in response -> add into chat_service too
    ChatService::OpenAiCompletionStream.new(prompt: prompt).call

    # sse = SSE.new(response.stream, event: "message")
    # client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])
    # begin
      # client.chat(
      #   parameters: {
      #     model: "gpt-3.5-turbo-16k",
      #     messages: [{ role: "user", content: params[:prompt] }],
      #     stream: proc do |chunk|
      #       content = chunk.dig('choices', 0, 'delta', 'content')
      #       return if content.nil?
      #       sse.write({ message: content })
      #     end
      #   }
      # )
    # ensure
    #   sse.close
    # end
  end
end
