class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @user = current_user
    @tasks = @user.tasks.order(:id).reverse
  end
end
