class ConversationsController < ApplicationController

  def new
    @conversation = Conversation.new
    @site = Site.find_by(id: params[:site_id])
  end

  def create
    users = User.where(id: params[:conversation][:user_ids].reject(&:empty?))
    users << current_user unless users.include?(current_user)
    site = Site.find_by(id: params[:conversation][:site_id])
    @conversation = site.find_conversation_by_users(users) || Conversation.new(conversation_params)

    if @conversation.valid?
      @conversation.save
      set_up_users(users) unless @conversation.users.count > 0
      create_message if params[:content]

      if request.xhr?
        render partial: "messages/message", locals: { message: @message }
      else
        flash[:notice] = "Conversation successfully created"
        redirect_to home_path
      end

    else
      flash[:warn] = "Unable to create conversation, please try again"
      redirect_to :back
    end
  end

  def add_user
    user = User.find_by(id: params[:user_id])
    site = Site.find_by(id: params[:conversation][:site_id])
    if user
      users = User.where(id: params[:user_ids].reject(&:empty?))
      users << user
      @conversation = site.find_conversation_by_users(users) || Conversation.new(conversation_params)

      set_up_users(users) unless @conversation.users.count > 0
      redirect_to home_path(user_ids: @conversation.user_ids, site_id: site.id)
    else
      flash[:warn] = "Unable to find user"
      redirect_to :back
    end
  end

  def destroy

  end

  private

  def conversation_by_id
    @conversation = Conversation.find_by(id: params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:site_id)
  end

  def set_up_users(users)
    users.each { |user| @conversation.users << user }
  end

  def create_message
    @message = Message.create(content: params[:content], user_id: current_user.id, conversation_id: @conversation.id)
    set_up_recipients
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