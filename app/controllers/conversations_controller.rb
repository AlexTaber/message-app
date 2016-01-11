class ConversationsController < ApplicationController

  def new
    @conversation = Conversation.new
    @site = Site.find_by(id: params[:site_id])
  end

  def create
    users = User.where(id: params[:conversation][:user_ids].reject(&:empty?))
    users << current_user unless users.include?(current_user)
    @site = Site.find_by(id: params[:conversation][:site_id])
    @conversation = @site.find_conversation_by_users(users) || Conversation.new(conversation_params)

    if @conversation.valid?
      set_up_users(users) unless @conversation.users.count > 0
      if @conversation.users.length > 1
        @conversation.save
      else
        flash[:warn] = "You must add at least one other user to the conversation. Please try again."
        redirect_to :back and return
      end
      create_message if params[:content]
      pusher_new_conversation unless @conversation.new_record?

      if request.xhr?
        render json: {
          html: (render_to_string partial: "messages/message", locals: { message: @message }),
          form_html: (render_to_string partial: "messages/form", locals: { message: Message.new, conversation: @conversation }),
          token: @conversation.token
        }
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
    @site = Site.find_by(id: params[:conversation][:site_id])
    if user
      users = User.where(id: params[:user_ids].reject(&:empty?))
      users << user
      @conversation = @site.find_conversation_by_users(users) || Conversation.new(conversation_params)

      set_up_users(users) unless @conversation.users.count > 0
      if params[:token].empty?
        redirect_to home_path(user_ids: @conversation.user_ids, site_id: @site.id)
      else
        redirect_to message_box_path(token: params[:token], user_ids: @conversation.user_ids)
      end
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

  def pusher_new_conversation
    @conversation.users.each do |user|
       Pusher.trigger("new-conversation#{user.id}", 'new-conversation', {
         app_html: (render_to_string partial: "conversations/app_card", locals: { conversation: @conversation, current_conversation: nil, site: @site, user: user }),
         mb_html: (render_to_string partial: "conversations/mb_card", locals: { conversation: @conversation, current_conversation: nil, site: @site, user: user })
      })
    end
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