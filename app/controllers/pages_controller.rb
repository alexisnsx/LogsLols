class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @tasks = current_user.tasks.order(:id).reverse
    @chat = current_user.chats.where(status:"current")[0]
    @conversation = Conversation.new
  end
end
