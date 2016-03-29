class TasksController < ApplicationController
  before_action :task_by_id, only: [:update, :destroy]

  def create
    redirect_to :back and return if existing_task?
    @task = Task.new(task_params)

    if @task.valid?
      @task.save
      flash[:notice] = "Task successfully created"
      fire_pusher_event(@task.id, @task.message, @task.message.conversation.users, true, false)
      new_task_emails
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
      fire_pusher_event(@task.id, @task.message, @task.message.conversation.users, false, false)
      completed_task_emails if @task.completed
    else
      flash[:warn] = "Unable to update task"
    end

    if request.xhr?
      render text: "Done"
    else
      redirect_to :back
    end
  end

  def destroy
    claims = @task.claims

    if @task
      task_id = @task.id
      message = @task.message
      users = @task.message.conversation.users
      @task.delete
      flash[:notice] = "Task Deleted"
      delete_claims(claims)
      fire_pusher_event(task_id, message, users, false, true)
    else
      flash[:warn] = "No task by that id"
    end

    if request.xhr?
      render text: "Done"
    else
      redirect_to :back
    end
  end

  private

  def task_params
    params.require(:task).permit(:message_id, :completer_id)
  end

  def task_by_id
    @task = Task.find_by(id: params[:id])
  end

  def fire_pusher_event(task_id, message, users, new_record, deleted)
    task = Task.find_by(id: task_id)
    users.each do |user|
      user == current_user ? current_conversation = message.conversation : current_conversation = nil
      Pusher.trigger("task#{message.conversation.token}#{user.id}", 'new-task', {
        message_id: message.id,
        task_id: task_id,
        user_id: message.user.id,
        conversation_token: message.conversation.token,
        conversation_id: message.conversation.id,
        current_user_html: (render_to_string partial: "messages/current_user_message", locals: { message: message, task: task }),
        other_user_html: (render_to_string partial: "messages/other_user_message", locals: { message: message, task: task }),
        task_html: task_html(task, user),
        note_html: note_html(message),
        notes_html: (render_to_string partial: "conversations/notes_card", locals: { conversation: message.conversation, current_conversation: current_conversation, project: message.conversation.project, user: user }),
        deleted: deleted,
        completer_id: task ? task.completer_id : false,
        completed_tasks_count: message.conversation.completed_tasks.count,
        app_html: (render_to_string partial: "conversations/app_card", locals: { conversation: message.conversation, current_conversation: current_conversation, project: message.conversation.project, user: user })
      })
    end
  end

  def task_html(task, user)
    task ? (render_to_string partial: "tasks/task", locals: { task: task, user: user } ) : ""
  end

  def note_html(message)
    (render_to_string partial: "messages/note", locals: { message: message } )
  end

  def new_task_emails
    @task.message.conversation.other_users(current_user).each do |user|
      UserMailer.new_task_email(@task, user).deliver_now if user.needs_task_notification?(@task)
    end
  end

  def completed_task_emails
    @task.message.conversation.other_users(current_user).each do |user|
      UserMailer.completed_task_email(@task, user).deliver_now if user.needs_task_notification?(@task)
    end
  end

  def existing_task?
    message = Message.find_by(id: params[:task][:message_id])
    message ? message.task : false
  end

  def delete_claims(claims)
    claims.each(&:delete)
  end
end