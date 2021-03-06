class MessagesController < ApplicationController
  def create
    current_user.update_last_online
    @message = Message.new(message_params)
    @message.default_content

    if @message.valid?
      redirect_to home_path and return unless current_user.is_member_of_project?(@message.conversation.project)
      @message.save!
      set_up_recipients
      set_up_task if params[:tasks]
      set_up_attachments(params[:message][:files]) if params[:message][:files]
      @message.conversation.users.each do |user|
        user == current_user ? current_conversation = @message.conversation : current_conversation = nil
        Pusher.trigger("conversation#{@message.conversation.token}#{user.id}", 'new-message', {
          user_id: @message.user.id,
          conversation_token: @message.conversation.token,
          current_user_html: (render_to_string partial: "messages/current_user_message", locals: { message: @message, task: @message.task }),
          other_user_html: (render_to_string partial: "messages/other_user_message", locals: { message: @message, task: @message.task }),
          task_html: task_html(user),
          note_html: note_html,
          notes_html: (render_to_string partial: "conversations/notes_card", locals: { conversation: @message.conversation, current_conversation: current_conversation, project: @message.conversation.project, user: user }),
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

  def destroy
    @message = Message.find_by(id: params[:id])
    conversation = @message.conversation

    if @message.destroy
      if request.xhr?
        render json: {
          id: conversation.id,
          html: (render_to_string partial: "conversations/notes_card", locals: { conversation: conversation, current_conversation: conversation, project: conversation.project, user: current_user })
        }
      else
        redirect_to home_path
      end
    else
      flash[:warn] = "Unable to delete message, please try again"
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

  def task_html(user)
    return false unless @message.task
    (render_to_string partial: "tasks/task", locals: { task: @message.task, message: @message, user: user } )
  end

  def note_html
    (render_to_string partial: "messages/note", locals: { message: @message } )
  end

  def new_message_emails
    if @message.task
      new_task_emails
    else
      @message.conversation.other_users(current_user).each do |user|
        UserMailer.new_message_email(@message, user).deliver_now if user.needs_notification?(@message)
      end
    end
  end

  def new_task_emails
    @message.conversation.other_users(current_user).each do |user|
      UserMailer.new_task_email(@message.task, user).deliver_now if user.needs_task_notification?(@message.task)
    end
  end

  def set_up_attachments(files)
    invalid_files = params[:invalid_files].split(",").map(&:to_i)
    files.each_with_index do |file, index|
      unless invalid_files.include?(index)
        obj = S3_BUCKET.object(file.original_filename)

        obj.upload_file(file.tempfile, acl:'public-read')

        attachment = Attachment.new(url: obj.public_url, message_id: @message.id, name: file.original_filename)
        unless attachment.save
          flash[:warn] = "There was a problem uploading your image, please try again"
          redirect_to :back
        end
      end
    end
  end
end
