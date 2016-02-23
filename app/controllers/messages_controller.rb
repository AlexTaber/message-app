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
          app_html: (render_to_string partial: "conversations/app_card", locals: { conversation: @message.conversation, current_conversation: current_conversation, site: @message.conversation.site, user: user })
        })
      end

      if request.xhr?
        render partial: "messages/message", locals: { message: @message }
      else
        redirect_to home_path(site_id: @message.conversation.site.id, conversation_id: @message.conversation.id)
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
end
