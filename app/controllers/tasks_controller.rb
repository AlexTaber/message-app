class TasksController < ApplicationController
  before_action :task_by_id, only: [:update, :destroy]

  def create
    @task = Task.new(task_params)

    if @task.valid?
      @task.save
      flash[:notice] = "Task successfully created"
      fire_pusher_event(@task, @task.message, @task.message.conversation.users, true)
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
      fire_pusher_event(@task, @task.message, @task.message.conversation.users, false)
    else
      flash[:warn] = "Unable to update task"
    end

    redirect_to :back
  end

  def destroy
    if @task
      message = @task.message
      users = @task.message.conversation.users
      @task.delete
      flash[:notice] = "Task Deleted"
      fire_pusher_event(nil, message, users, false)
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

  def fire_pusher_event(task, message, users, new_record)
    users.each do |user|
      Pusher.trigger("task#{message.conversation.token}#{user.id}", 'new-task', {
        message_id: message.id,
        user_id: message.user.id,
        conversation_token: message.conversation.token,
        current_user_html: (render_to_string partial: "messages/current_user_message", locals: { message: message, task: task }),
        other_user_html: (render_to_string partial: "messages/other_user_message", locals: { message: message, task: task }),
        task_html: task_html(task, new_record)
      })
    end
  end

  def task_html(task, new_record)
    new_record ? (render_to_string partial: "tasks/task", locals: { task: task } ) : ""
  end
end