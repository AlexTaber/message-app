class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params)

    if @message.valid?
      @message.save!
      flash[:notice] = "Message successfully created"
      redirect_to home_path(site_id: @message.conversation.site.id, conversation_id: @message.conversation.id)
    else
      flash[:warn] = "Unable to create message, please try again"
      redirect_to :back
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :user_id, :conversation_id)
  end
end
