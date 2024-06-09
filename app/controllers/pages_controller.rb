class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @tasks = current_user.tasks.order(:id)
  end
end
