class TasksController < ApplicationController
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :original, :completion ]

  def index
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
    render json: { task_id: task_id, title: task.title, content: task.content.body }
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
    @tasks = current_user.tasks
    @tasks = @tasks.search_full_text(@query) if @query.present?

    if params[:sorted].present?
      case params[:sorted]
      when "priority"
        @tasks = Task.where(user: current_user).in_order_of(:priority, ["High", "Medium", "Low"])
        @tasks = @tasks.search_full_text(@query) if @query.present?
      when "status"
        @tasks = Task.where(user: current_user).in_order_of(:status, ["Incomplete", "Complete"])
        @tasks = @tasks.search_full_text(@query) if @query.present?
      when "due_date"
        @tasks = Task.where(user: current_user).order(:due_date)
        @tasks = @tasks.search_full_text(@query) if @query.present?
      end
    end

    render json: {
      task_cards: render_to_string(
        partial: 'tasks/index',
        locals: { tasks: @tasks },
        formats: [:html]
      )
    }
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :content, :priority, :due_date, :status, :reminder_datetime, documents: [])
  end

  def sorted_by(current_user, field)
    return current_user.tasks.order(:status).reverse if field == 'status'

    return current_user.tasks.order(field)
  end
end

  # if params[:sorted] && (params[:sorted] != 'none')
  #   @tasks = current_user.tasks.ordered_by_priority_and_name.search_full_text(@query)
  # else
  #   @tasks = current_user.tasks.search_full_text(@query)
  # end

  # if @tasks.empty?
  #   if params[:sorted] && (params[:sorted] != 'none')
  #     @tasks = current_user.tasks.order(params[:sorted])
  #   else
  #     @tasks = current_user.tasks.order(:id).reverse
  #   end
  # end

  # if params[:sorted] == "priority"
  #   @tasks = current_user.tasks.order(:priority)
  # end
  # if params[:sorted] == "status"
  #   @tasks = current_user.tasks.order(:status).reverse
  # end
  # if params[:sorted] == "due_date"
  #   @tasks = current_user.tasks.order(:due_date)
  # end


# def filter
#   puts "paramshere>"
#   puts params
#   filters = {}
#   if params[:priority]
#     filters[:priority] = params[:priority]
#   end
#   if params[:status]
#     filters[:status] = params[:status]
#   end
#   if params[:dueDate]
#     filters[:due_date] = params[:dueDate]
#   end

  # filters[:priority] = params[:priority] == 'None' ? nil : params[:priorty]
  # puts "filters>>"
  # puts filters
  # @tasks = Task.where(filters)
  # # @tasks = Task.where(priority: params[:priority], status: params[:status])

  # puts(@tasks)

  # render json: {
  #   task_cards: render_to_string(
  #     partial: 'tasks/index',
  #     locals: { tasks: @tasks },
  #     formats: [:html]
  #   )
  # }
# end
