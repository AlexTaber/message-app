class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params)

    if @message.valid?
      @message.save!
      set_up_recipients
      set_up_task if params[:tasks]
      @message.conversation.users.each do |user|
        user == current_user ? current_conversation = @message.conversation : current_conversation = nil
        Pusher.trigger("conversation#{@message.conversation.token}#{user.id}", 'new-message', {
          user_id: @message.user.id,
          conversation_token: @message.conversation.token,
          current_user_html: (render_to_string partial: "messages/current_user_message", locals: { message: @message, task: @message.task }),
          other_user_html: (render_to_string partial: "messages/other_user_message", locals: { message: @message, task: @message.task }),
          task_html: task_html,
          conversation_id: @message.conversation.id,
          project_id: @message.conversation.project.id,
          app_html: (render_to_string partial: "conversations/app_card", locals: { conversation: @message.conversation, current_conversation: current_conversation, project: @message.conversation.project, user: user })
        })
      end

      new_message_emails

      if request.xhr?
        render partial: "messages/message", locals: { message: @message }
      else
        redirect_to home_path(project_id: @message.conversation.project.id, conversation_id: @message.conversation.id)
      end

    else
      flash[:warn] = "Unable to create message, please try again"
      redirect_to :back
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :user_id, :conversation_id)
  end

  def set_up_recipients
    @message.conversation.other_users(current_user).each do |user|
      MessageUser.create(
        user_id: user.id,
        message_id: @message.id
      )
    end
  end

  def set_up_task
    @task = Task.create(message_id: @message.id)
  end

  def task_html
    return false unless @message.task
    (render_to_string partial: "tasks/task", locals: { task: @message.task } )
  end

  def new_message_emails
    @message.conversation.other_users(current_user).each do |user|
      UserMailer.new_message_email(@message, user).deliver_now if user.needs_notification?(@message)
    end
  end
end
