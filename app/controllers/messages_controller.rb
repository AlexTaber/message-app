class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params)

    if @message.valid?
      @message.save!
      set_up_recipients
      flash[:notice] = "Message successfully created"
      Pusher.trigger("conversation#{@message.conversation.token}", 'new-message', {
        user_id: @message.user.id,
        current_user_html: (render_to_string partial: "messages/current_user_message", locals: { message: @message }),
        other_user_html: (render_to_string partial: "messages/other_user_message", locals: { message: @message })
      })

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
end
