class ConversationsController < ApplicationController
  def new
    @conversation = Conversation.new
    @site = Site.find_by(id: params[:site_id])
  end

  def create
    @conversation = Conversation.new(conversation_params)

    if @conversation.valid?
      @conversation.save
      set_up_users
      create_message if params[:content]
      flash[:notice] = "Conversation successfully created"
      redirect_to home_path
    else
      flash[:warn] = "Unable to create conversation, please try again"
      redirect_to :back
    end
  end

  def destroy

  end

  private

  def conversation_params
    params.require(:conversation).permit(:site_id)
  end

  def set_up_users
    user_ids = params[:conversation][:user_ids].reject!(&:empty?)
    if user_ids.count > 0
      user_ids.each do |user_id|
        @user = User.find_by(id: user_id)
        @conversation.users << @user
      end
      @conversation.users << current_user
    else
      flash[:warn] = "A conversation must have users, please try again"
      redirect_to :back
      return
    end
  end

  def create_message
    @message = Message.new(content: params[:content], user_id: current_user.id)
    @conversation.messages << @message
  end
end