class UsersController < ApplicationController
  before_action :require_current_user, only: [:home]
  before_action :require_permitted_user, only: [:home, :message_box]
  before_action :user_by_id, only: [:edit, :update, :user_owner_data]

  def new
    @default_tier_id = params[:default_tier_id] || 1

    if current_user
      redirect_to edit_user_path(current_user, default_tier_id: @default_tier_id)
    else
      @user = User.new
      @invite = token_invite(params[:invite_token])
    end
  end

  def create
    @user = User.new(user_params)
    @user.format_new_user

    if @user.confirm_password(params[:confirm_password])
      if @user.valid?
        @user.save
        @subscription = Subscription.new(user_id: @user.id)
        tier = Tier.find_by(id: 1)
        @subscription.save_with_payment(tier, false)
        send_welcome_email(@user)
        upload_image(params[:user][:file]) if params[:user][:file]
        set_up_invite if params[:invite_token]
        flash[:notice] = "User successfully created"
        cookies.permanent.signed[:user_id] = @user.id
        redirect_to home_path
      else
        flash[:warn] = "Unable to create user, please try again"
        redirect_to :back
      end
    else
      flash[:warn] = "Password/Confirm Password fields do not match, please try again"
      redirect_to :back
    end
  end

  def edit
    @default_tier_id = params[:default_tier_id] || current_user.tier.id
  end

  def update
    if params[:user][:tier_id]
      flash[:warn] = "Unable to process user data. An email has been sent to admin@mercuryapp.co to resolve this issue"
      redirect_to :back and return
    end

    set_update_password
    @user.assign_attributes(user_params)

    if @user.confirm_password(params[:confirm_password])
      if @user.valid?
        @user.save
        upload_image(params[:user][:file]) if params[:user][:file]
        flash[:notice] = "User successfully updated"
        redirect_to home_path
      else
        flash[:warn] = "Unable to update user, please try again"
        redirect_to :back
      end
    else
      flash[:warn] = "Password/Confirm Password fields do not match, please try again"
      redirect_to :back
    end
  end

  def destroy
  end

  def home
    current_user.update_last_online
    redirect_to new_subscription_path and return unless current_user.subscription

    current_user.has_active_projects? ? find_user_project : @project = Project.new
    unless current_user.permitted_on_project?(@project)
      session[:project_id] = nil #just to be safe
      flash[:warn] = "You are not permitted to view this project"
      redirect_to splash_path and return
    end

    if params[:new_conversation]
      set_up_new_conversation
    elsif params[:conversation_id]
      @conversation = Conversation.find_by(id: params[:conversation_id])
      set_up_new_conversation unless @conversation
    else
      current_user.has_conversations_by_project?(@project) ? find_conversation(current_user) : set_up_new_conversation
    end
    unless @conversation.user_is_permitted?(current_user)
      flash[:warn] = "You are not permitted to view this conversation"
      redirect_to home_path and return
    end

    set_up_notes
    @conversation.read_all_messages(current_user) unless @conversation.new_record?
    @message = Message.new
    @new_project = Project.new
    @new_conversation = Conversation.new
    current_user.admin_of_project?(@project) ? @admin_project = @project : @admin_project = nil
    current_user.add_visit
    @invite = Invite.new
    @request = Request.new
    @tasks = params[:tasks]
    @notes = params[:notes]
    @mobile_conversations = params[:mobile_conversations]
    @lazy_load = find_lazy_load
    @has_active_projects = current_user.has_active_projects?
  end

  def message_box_data
    @json = Hash.new
    @json[:project] = current_user.find_project_by_url(params[:url])
    if @json[:project]
      set_up_json
    end

    render json: @json
  end

  def message_box

    if current_user
      current_user.update_last_online
      find_user_project
      unless @project
        redirect_to mb_new_project_path
      else
        if current_user.projects.include?(@project)
          if params[:new_conversation]
            set_up_new_conversation
          else
            current_user.has_conversations_by_project?(@project) ? find_conversation(current_user) : set_up_new_conversation
            @conversation.read_all_messages(current_user) unless @conversation.new_record?
            @message = Message.new
          end
          set_up_notes
          @tasks = params[:tasks]
          @notes = params[:notes]
          @lazy_load = find_lazy_load
        else
          flash[:warn] = "You are not a member of that project"
          session[:project_id] = nil
          redirect_to message_box_path
        end
      end
    else
      redirect_to mb_login_path
    end
  end

  def mb_new_project

  end

  def typeahead
    project = Project.find_by(id: params[:project_id])
    if project
      render json: {
        project_users: project.typeahead_users_data(current_user),
        all_users: project.non_member_users_data,
        all_projects: Project.all_projects_data
      }.to_json
    else
      render json: {
        all_projects: Project.all_projects_data
      }.to_json
    end
  end

  def owner_data
    require_owner
    @recent_users = User.all.order(id: :desc).limit(5)
    @recent_projects = Project.all.order(id: :desc).limit(5)
    @time = [params[:time].to_i, 1].max
  end

  def users_data
    @users = User.all.order(id: :desc)
  end

  def user_owner_data

  end

  def validate
    @user = User.new(user_params)

    if request.xhr?
      render json: @user.validation_response.to_json
    end
  end

  def plugin_info

  end

  private

  def user_by_id
    @user = User.find_by(id: params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :password, :email, :tier_id)
  end

  def find_user_project
    if params[:project_id]
      @project = Project.find_by(id: params[:project_id])
      set_project_session if @project
    elsif session[:project_id]
      @project = Project.find_by(id: session[:project_id])
    else
      @project = current_user.active_projects_ordered_by_admin.first
      set_project_session if @project
    end
  end

  def set_project_session
    session[:project_id] = @project.id
  end

  def find_conversation(user)
    if params[:user_ids]
      users = User.where(id: params[:user_ids])
      @conversation = Conversation.find_conversation_by_users_and_project(users, @project)
      unless @conversation
        @conversation = Conversation.new(project_id: @project.id)
        @conversation.users << users
      end
    else
      @conversation = user.ordered_conversations_by_project(@project).first
    end
  end

  def set_up_json
    @json[:conversations] = current_user.conversations_to_json(@json[:project])
  end

  def upload_image(file)
    obj = S3_BUCKET.object(file.original_filename)

    obj.upload_file(file.tempfile, acl:'public-read')
    @user.remove_image if @user.image
    @image = Image.new(url: obj.public_url, imageable_id: @user.id, imageable_type: "User")
    unless @image.save
      flash[:warn] = "There was a problem uploading your image, please try again"
      redirect_to :back
    end
  end

  def set_up_invite
    @invite = token_invite(params[:invite_token])
    create_user_project if @invite
    @invite.delete
  end

  def create_user_project
    UserProject.create(
      user_id: @user.id,
      project_id: @invite.project.id,
      admin: false
    )
  end

  def set_up_new_conversation
    @conversation = Conversation.new(project_id: @project.id)
    if params[:user_ids]
      users = User.where(id: params[:user_ids])
      @conversation.users << users
    else
      @conversation.users << current_user
    end
  end

  def send_welcome_email(user)
    UserMailer.welcome_email(user).deliver_now
  end

  def set_update_password
    if params[:user][:password] == ""
      params[:user].delete("password")
      params.delete("confirm_password")
    end
  end

  def find_lazy_load
    params[:lazy_load] ? params[:lazy_load].to_i + 1 : 0;
  end

  def set_up_notes
    @notes_conversation = @project.find_notes(current_user)
    unless @notes_conversation
      @notes_conversation = Conversation.create(project: @project)
      @notes_conversation.users << current_user
    end

    @conversation = @notes_conversation if params[:notes]
  end
end
