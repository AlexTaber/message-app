class TasksController < ApplicationController
  before_action :task_by_id, only: [:update, :destroy]

  def create
    @task = Task.new(task_params)

    if @task.valid?
      @task.save
      flash[:notice] = "Task successfully created"
    else
      flash[:warn] = "Unable to create task"
    end

    redirect_to :back
  end

  def update
    @task.assign_attributes(task_params)

    if @task.valid?
      @task.save
      flash[:notice] = "Task successfully updated"
    else
      flash[:warn] = "Unable to update task"
    end

    redirect_to :back
  end

  def destroy
    if @task
      @task.delete
      flash[:notice] = "Task Deleted"
    else
      flash[:warn] = "No task by that id"
    end

    redirect_to :back
  end

  private

  def task_params
    params.require(:task).permit(:message_id, :completed)
  end

  def task_by_id
    @task = Task.find_by(id: params[:id])
  end
end