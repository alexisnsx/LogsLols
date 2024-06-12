class TasksController < ApplicationController
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :original, :completion ]

  def index
    @tasks = current_user.tasks
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
    @task.user = current_user

    respond_to do |format|
      if @task.save
        format.html { redirect_to root_path }
        format.json
        flash[:notice] = "'#{@task.title}' task successfully saved!"
      else
        format.html { render partial: 'new', status: :unprocessable_entity }
        format.json
      end
    end
  end

  def original
    tasks = Task.all
    @index = tasks.index(@task)
    respond_to do |format|
      format.html
      # format.text { render plain: 'test' }
      format.text { render partial: 'tasks/task', locals: { task: @task, index: @index }, formats: [:html] }
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.text { render partial: 'edit', locals: { task: @task }, formats: [:html] }
    end
  end

  def update
    tasks = Task.all
    @index = tasks.index(@task)
    respond_to do |format|
      if @task.update(task_params.except(:documents))
        @task.documents.attach(task_params[:documents])
        format.html { redirect_to root_path }
        format.json 
        # format.json { render partial: "tasks/task", locals: { task: @task, index: @index }, formats: [:html] }
      end
    end
  end

  def completion
    respond_to do |format|
      if @task.status == 'Incomplete'
        @task.update(status: 'Complete')
        format.html
        format.text { render partial: "checkbox", locals: { task: @task }, formats: [:html] }
      else
        @task.update(status: 'Incomplete')
        format.html
        format.text { render partial: "checkbox", locals: { task: @task }, formats: [:html] }
      end
    end
  end

  def destroy
    @task.destroy
    flash[:alert] = "'#{@task.title}' deleted!"
    redirect_to root_path, status: :see_other
  end

  def get_tasks_due
    current_time = Time.zone.now
    @tasks = Task.where.not(reminder_datetime: nil)
    reminders = @tasks

    ReminderChannel.broadcast_to(
      current_user,
      {
        task_ids: @tasks.pluck(:id),
        reminders: render_to_string(partial: "tasks/reminders", locals: {reminders: reminders}, formats: [:html])
      }
    )

    @tasks.update_all(reminder_datetime: nil)
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
