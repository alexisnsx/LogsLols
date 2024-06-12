class ConversationResponsesController < ApplicationController
  include ActionController::Live # allows us to stream response based on server-sent events

  def index
    response.headers['Content-Type'] = "text/event-stream"
    response.headers['Last-Modified'] = Time.now.httpdate
    prompt = params[:prompt]

    # Change this service whenever another is needed
    ChatService::GroqCompletionStream.new(prompt: prompt, response: response).call
  end
end
