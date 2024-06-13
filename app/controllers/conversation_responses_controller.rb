class ConversationResponsesController < ApplicationController
  include ActionController::Live # allows us to stream response based on server-sent events

  def index
    response.headers['Content-Type'] = "text/event-stream"
    response.headers['Last-Modified'] = Time.now.httpdate
    prompt = params[:prompt]
    # Change this service whenever another is needed
    begin
      GroqchatService::ToolUseStream.new(prompt: prompt, response: response).call
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
      GroqchatService::RescueStream.new(response: response).call
    end

  end
end
