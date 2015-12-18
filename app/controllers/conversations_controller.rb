class ConversationsController < ApplicationController
  def new
    @conversation = Conversation.new
    @site = Site.find_by(id: params[:site_id])
  end

  def create
    users = User.where(id: params[:conversation][:user_ids].reject!(&:empty?))
    users << current_user
    site = Site.find_by(id: params[:conversation][:site_id])
    @conversation = site.find_conversation_by_users(users) || Conversation.new(conversation_params)

    if @conversation.valid?
      @conversation.save
      set_up_users(users) unless @conversation.users.count > 0
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

  def set_up_users(users)
    users.each { |user| @conversation.users << user }
  end

  def create_message
    @message = Message.new(content: params[:content], user_id: current_user.id)
    @conversation.messages << @message
  end
end