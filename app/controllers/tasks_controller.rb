class TasksController < ApplicationController
  before_action :task_by_id, only: [:update, :destroy]

  def create
    @task = Task.new(task_params)

    if @task.valid?
      @task.save
      flash[:notice] = "Task successfully created"
      fire_pusher_event(true)
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
      fire_pusher_event(false)
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

  def fire_pusher_event(new_record)
    @task.message.conversation.users.each do |user|
      Pusher.trigger("task#{@task.message.conversation.token}#{user.id}", 'new-task', {
        message_id: @task.message.id,
        user_id: user.id,
        conversation_token: @task.message.conversation.token,
        current_user_html: (render_to_string partial: "messages/current_user_message", locals: { message: @task.message, task: @task }),
        other_user_html: (render_to_string partial: "messages/other_user_message", locals: { message: @task.message, task: @task }),
        task_html: task_html(new_record)
      })
    end
  end

  def task_html(new_record)
    new_record ? (render_to_string partial: "tasks/task", locals: { task: @task } ) : ""
  end
end