class ConversationsController < ApplicationController

  def new
    @conversation = Conversation.new
    @project = Project.find_by(id: params[:project_id])
  end

  def create
    users = User.where(id: params[:conversation][:user_ids].reject(&:empty?))
    users << current_user unless users.include?(current_user)
    @project = Project.find_by(id: params[:conversation][:project_id])
    @conversation = @project.find_conversation_by_users(users) || Conversation.new(conversation_params)

    if @conversation.valid?
      redirect_to home_path and return unless current_user.is_member_of_project?(@conversation.project)
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
        if params[:tasks]
          render json: {
            html: (render_to_string partial: "tasks/task", locals: { task: @task, message: @message, user: current_user }),
            form_html: (render_to_string partial: "messages/form", locals: { message: Message.new, conversation: @conversation, notes: params[:notes], tasks: params[:tasks] }),
            token: @conversation.token
          }
        else
          render json: {
            html: (render_to_string partial: "messages/message", locals: { message: @message }),
            form_html: (render_to_string partial: "messages/form", locals: { message: Message.new, conversation: @conversation, notes: params[:notes], tasks: params[:tasks] }),
            token: @conversation.token
          }
        end
      else
        flash[:notice] = "Conversation successfully created"
        redirect_to home_path(tasks: params[:tasks])
      end

    else
      flash[:warn] = "Unable to create conversation, please try again"
      redirect_to :back
    end
  end

  def show
    @conversation = Conversation.find_by(id: params[:id])
    project = Project.find_by(id: params[:project_id])
    tasks = is_true?(params[:tasks])
    notes = is_true?(params[:notes])
    message = Message.new
    render partial: "message_center", locals: { conversation: @conversation, project: project, notes: notes, tasks: tasks, message: message }
  end

  def add_user
    user = User.find_by(id: params[:user_id])
    @project = Project.find_by(id: params[:conversation][:project_id])
    if user
      users = User.where(id: params[:user_ids].reject(&:empty?))
      users << user
      @conversation = @project.find_conversation_by_users(users) || Conversation.new(conversation_params)

      set_up_users(users) unless @conversation.users.count > 0
      if params[:token].empty?
        redirect_to home_path(user_ids: @conversation.user_ids, project_id: @project.id, tasks: params[:tasks])
      else
        redirect_to message_box_path(token: params[:token], user_ids: @conversation.user_ids, tasks: params[:tasks])
      end
    else
      flash[:warn] = "Unable to find user"
      redirect_to :back
    end
  end

  def destroy

  end

  def lazy_load
    @conversation = token_conversation(params[:token])
    if params[:notes] == "true"
      render partial: "notes_lazy_load", locals: { conversation: @conversation, lazy_load: params[:lazy_load].to_i }
    else
      render partial: "lazy_load", locals: { conversation: @conversation, lazy_load: params[:lazy_load].to_i }
    end
  end

  def app_messages
    conversation = token_conversation(params[:conversation_token]) || Conversation.new
    project = Project.find_by(id: params[:project_id])
    tasks = is_true?(params[:tasks])
    notes = is_true?(params[:notes])
    lazy_load = params[:lazy_load].to_i
    render partial: "app_messages", locals: { conversation: conversation, tasks: tasks, notes: notes, lazy_load: lazy_load, project: project }
  end

  def read_messages
    conversation_by_id
    @conversation.read_all_messages(current_user)

    render text: "done"
  end

  private

  def conversation_by_id
    @conversation = Conversation.find_by(id: params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:project_id)
  end

  def set_up_users(users)
    users.each { |user| @conversation.users << user }
  end

  def pusher_new_conversation
    @conversation.users.each do |user|
      user == current_user ? current_conversation = @conversation : current_conversation = nil
      Pusher.trigger("new-conversation#{user.id}", 'new-conversation', {
         app_html: (render_to_string partial: "conversations/app_card", locals: { conversation: @conversation, current_conversation: current_conversation, project: @project, user: user }),
         mb_html: (render_to_string partial: "conversations/mb_card", locals: { conversation: @conversation, current_conversation: current_conversation, project: @project, user: user }),
         project_id: @project.id
      })
    end
  end

  def create_message
    @message = Message.create(content: params[:content], user_id: current_user.id, conversation_id: @conversation.id)
    create_task if params[:tasks]
    set_up_recipients
    new_message_email
  end

  def set_up_recipients
    @message.conversation.other_users(current_user).each do |user|
      MessageUser.create(
        user_id: user.id,
        message_id: @message.id
      )
    end
  end

  def create_task
    @task = Task.create(message_id: @message.id)
  end

  def new_message_email
    @conversation.other_users(current_user).each { |user| UserMailer.new_message_email(@message, user).deliver_now }
  end
end