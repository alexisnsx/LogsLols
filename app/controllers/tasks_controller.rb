class TasksController < ApplicationController
before_action :set_task, only: [ :show, :edit, :update, :destroy ]

  def index
    @tasks = current_user.tasks
    @reminder = Reminder.new
  end

  def show
    respond_to do |format|
      format.html
      format.js { render partial: 'show', locals: { task: @task } }
    end
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.reminder_datetime.change(usec: 0)
    @task.user = current_user
    if @task.save
      flash[:notice] = "'#{@task.title}' task successfully saved!"
      # ReminderChannel.broadcast_to(
      #   current_user,
      #   "<li>#{@task.title}</li>"
      #   #render_to_string(partial: "message", locals: {message: @message})
      # )
      redirect_to task_path(@task), status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @task.reminder_datetime.change(usec: 0)
    if @task.update(task_params.except(:documents))
      @task.documents.attach(task_params[:documents])
      flash[:notice] = "'#{@task.title}' updated successfully!"
      redirect_to task_path(@task), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    flash[:alert] = "'#{@task.title}' task deleted!"
    redirect_to tasks_path, status: :see_other
  end

  def get_tasks_due
    current_time = Time.zone.now
    @tasks = Task.where("reminder_datetime <= ? AND status != ?", current_time, 'notified')
    reminders = @tasks

    ReminderChannel.broadcast_to(
      current_user,
      {
        task_ids: @tasks.pluck(:id),
        reminders: render_to_string(partial: "tasks/reminders", locals: {reminders: reminders}, formats: [:html])
      }
    )

    @tasks.update_all(status: 'notified')
    head :ok
  end

  private
  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :due_date, :status, :reminder_datetime, documents: [])
  end
end
