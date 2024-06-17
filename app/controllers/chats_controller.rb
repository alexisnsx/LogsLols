class ChatsController < ApplicationController
  def index
    @chat = Chat.last
    render json: { chat_id: @chat.id }
  end

  def create
    @chat = Chat.create!(user: current_user)
    render json: { chat_id: @chat.id }
  end
end
