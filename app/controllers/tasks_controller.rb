class TasksController < ApplicationController
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
    @task = Task.find_by(id: params[:id])
    @task.assign_attributes(task_params)

    if @task.valid?
      @task.save
      flash[:notice] = "Task successfully updated"
    else
      flash[:warn] = "Unable to update task"
    end

    redirect_to :back
  end

  private

  def task_params
    params.require(:task).permit(:message_id, :completed)
  end
end