class TasksController < ApplicationController
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :original, :completion ]

  def index
    @tasks = Task.all
    @tasks = current_user.tasks
    @query = params[:search]
    if query.present?
      @tasks = Task.text_search(query)
    else
      @tasks = Task.all
    end
  end

  def show
    respond_to do |format|
      format.html
      format.text { render partial: 'show', locals: { task: @task }, formats: [:html] }
    end
  end

  def show_ai
    task_id = params[:id]
    task = Task.find(task_id)
    render json: { title: task.title, description: task.description }
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
        # flash[:notice] = "'#{@task.title}' task successfully saved!"
      else
        format.html { render partial: 'new', status: :unprocessable_entity }
        format.json
      end
    end
  end

  def original
    respond_to do |format|
      format.html
      # format.text { render plain: 'test' }
      format.text { render partial: 'tasks/task', locals: { task: @task }, formats: [:html] }
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.text { render partial: 'edit', locals: { task: @task }, formats: [:html] }
    end
  end

  def update
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
    notice = @task.title
    respond_to do |format|
      if @task.destroy
        # head :ok
        format.html
        format.text { render partial: "notice", locals: { notice: notice }, formats: [:html]}
      else
        format.html { render partial: 'index', status: :unprocessable_entity }
        format.json
      end
    end
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

  def search
    @query = params[:q]
    @tasks = current_user.tasks.search_full_text(@query)
    if @tasks.empty?
      @tasks = current_user.tasks.order(:id).reverse
    end
    render json: {
      task_cards: render_to_string(
        partial: 'tasks/index',
        locals: { tasks: @tasks },
        formats: [:html]
      )
    }
    # @tasks = Task.where("description ILIKE ?", "%#{@query}%")
    # render json: {
    #   task_cards: render_to_string(
    #     partial: 'tasks/index',
    #     locals: { tasks: @tasks },
    #     formats: [:html]
    #   )
    # }
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :content, :priority, :due_date, :status, :reminder_datetime, documents: [])
  end
end
