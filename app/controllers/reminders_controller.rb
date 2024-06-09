class RemindersController < ApplicationController
  def create
   # task id => get the task
    @task = Task.find(params[:task_id])
   #create the reminder
    @reminder = Reminder.new
    @reminder.task = @task
    if @reminder.save
      # if the reminder saves => send to the channe;
      flash[:notice] "your task is due #{@task.title}"
      head :ok
    end
  end
end
