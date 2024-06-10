class TasksController < ApplicationController
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :complete, :incomplete ]

  def index
    @tasks = current_user.tasks
  end

  def show
    respond_to do |format|
      format.html
      format.js { render partial: 'show', locals: { task: @task }, formats: [:html] }
    end
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.user = current_user

    respond_to do |format|
    if @task.save
      format.html ( redirect_to task_path(@task) )
      format.json
      flash[:notice] = "'#{@task.title}' successfully saved!"
    else
      format.html { render "tasks/new", status: :unprocessable_entity }
      format.json
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.text { render partial: 'tasks/form', locals: { task: @task} , formats: [:html] }
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params.except(:documents))
          @task.documents.attach(task_params[:documents])
          flash[:notice] = "'#{@task.title}' updated successfully!"
      # redirect_to root_path, status: :see_other
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

  private
  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :due_date, :status, :reminder_datetime, documents: [])
  end
end
