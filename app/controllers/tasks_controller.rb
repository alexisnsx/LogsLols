class TasksController < ApplicationController
  def index
    @tasks = current_user.tasks
  end

  def show
    # @reminder_datetime = reminder_datetime.find(params[:id])
  end
end
