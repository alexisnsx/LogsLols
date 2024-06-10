class TasksController < ApplicationController
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :complete, :incomplete ]

  def index
    @tasks = current_user.tasks
    @reminder = Reminder.new
  end

  def show
    respond_to do |format|
      format.html
      format.text { render partial: 'show', locals: { task: @task }, formats: [:html] }
    end
  end

  def new
    @task = Task.new
    respond_to do |format|
      format.html
      format.text { render partial: 'new', locals: { task: @task }, formats: [:html] }
    end
  end

  def create
    @task = Task.new(task_params)
    @task.reminder_datetime.change(usec: 0)
    @task.user = current_user
    if @task.save
      flash[:notice] = "'#{@task.title}' task successfully saved!"
      redirect_to task_path(@task), status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js { render partial: 'form', locals: { task: @task } }
    end
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
    flash[:alert] = "'#{@task.title}' deleted!"
    redirect_to root_path, status: :see_other
  end

  def complete
    @task.update(status: 'Complete')
    # flash[:notice] = "'#{@task.title}' marked as complete"
    render status: 200, json: { message: 'OK'}
  end

  def incomplete
    @task.update(status: 'Incomplete')
    # flash[:notice] = "'#{@task.title}' marked as incomplete"
    render status: 200, json: { message: 'OK'}
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
