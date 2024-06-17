class ConversationsController < ApplicationController
  def index
    @user = current_user
  end

  def create
    chat_id = params[:chat_id]
    body = params[:body]
    user_msg = "This is my task, help me"
    render json: { chat_id: chat_id, body: body, user_msg: user_msg }
    # @chat = Chat.find(chat_id)
    # @conversation = Conversation.new(chat: @chat)
  end
end
