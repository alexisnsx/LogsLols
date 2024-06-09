class TasksController < ApplicationController
before_action :set_task, only: [ :show, :edit, :update, :destroy ]

  def index
    @tasks = current_user.tasks
    @reminder = Reminder.new
  end

  def show
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
    current_time = DateTime.now
    current_time.change(usec: 0)
    # find tasks where reminder_datet ime === current_time
    puts 'get_tasks_due'
    puts current_time
    # handling for multiple tasks
    @task = Task.all[0]
    # @task = Task.find_by(reminder_datetime: current_time)
    puts "tasks:"
    puts @task
    if @task
      ReminderChannel.broadcast_to(
        current_user,
        "<li>#{@task.title}</li>"
        #render_to_string(partial: "message", locals: {message: @message})
      )
    end
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
