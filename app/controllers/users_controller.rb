class UsersController < ApplicationController
  before_action :user_by_id, only: [:edit, :update]

  def new
    @default_tier_id = params[:default_tier_id] || 1

    if current_user
      redirect_to edit_user_path(current_user, default_tier_id: @default_tier_id)
    else
      @user = User.new
      @invite_token = params[:invite_token]
    end
  end

  def create
    @user = User.new(user_params)
    @user.assign_attributes(email: @user.email.downcase)

    if @user.confirm_password(params[:confirm_password])
      if @user.valid?
        @user.save
        send_welcome_email(@user)
        upload_image(params[:user][:file]) if params[:user][:file]
        set_up_invite if params[:invite_token]
        flash[:notice] = "User successfully created"
        cookies.permanent.signed[:user_id] = @user.id
        if params[:tier_id].to_i > 1 then redirect_to new_subscription_path(tier_id: params[:tier_id]) else redirect_to home_path end
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
    current_user.has_active_sites? ? find_user_site : @site = Site.new
    if params[:new_conversation]
      set_up_new_conversation
    else
      current_user.has_conversations_by_site?(@site) ? find_conversation(current_user) : set_up_new_conversation
    end
    @conversation.read_all_messages(current_user) unless @conversation.new_record?
    @message = Message.new
    @new_site = Site.new
    @new_conversation = Conversation.new
    current_user.admin_of_site?(@site) ? @admin_site = @site : @admin_site = nil
    current_user.add_visit
    @invite = Invite.new
    @request = Request.new
  end

  def message_box_data
    @json = Hash.new
    @json[:site] = current_user.find_site_by_url(params[:url])
    if @json[:site]
      set_up_json
    end

    render json: @json
  end

  def message_box
    token = params[:token]

    if current_user
      @site = token_site(token)
      unless @site
        redirect_to token_redirect_path
      else
        if current_user.sites.include?(@site)
          current_user.has_conversations_by_site?(@site) ? find_conversation(current_user) : set_up_new_conversation
          @conversation.read_all_messages(current_user) unless @conversation.new_record?
          @message = Message.new
        else
          redirect_to new_request_path(token: token)
        end
      end
    else
      redirect_to mb_login_path(token: token)
    end
  end

  def token_redirect

  end

  def typeahead
    site = Site.find_by(id: params[:site_id])
    if site
      render json: {
        site_users: site.typeahead_users_data(current_user),
        all_users: site.non_member_users_data,
        all_sites: Site.all_sites_data
      }.to_json
    else
      render json: {
        all_sites: Site.all_sites_data
      }.to_json
    end
  end

  private

  def user_by_id
    @user = User.find_by(id: params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :password, :email, :tier_id)
  end

  def find_user_site
    params[:site_id] ? @site = Site.find_by(id: params[:site_id]) : @site = current_user.active_sites_ordered_by_admin.first
  end

  def find_conversation(user)
    if params[:user_ids]
      users = User.where(id: params[:user_ids])
      @conversation = Conversation.find_conversation_by_users_and_site(users, @site)
      unless @conversation
        @conversation = Conversation.new(site_id: @site.id)
        @conversation.users << users
      end
    else
      @conversation = user.conversations_by_site(@site).first
    end
  end

  def set_up_json
    @json[:conversations] = current_user.conversations_to_json(@json[:site])
  end

  def upload_image(file)
    obj = S3_BUCKET.object(file.original_filename)

    obj.upload_file(file.tempfile, acl:'public-read')

    @image = Image.new(url: obj.public_url, imageable_id: @user.id, imageable_type: "User")

    unless @image.save
      flash[:warn] = "There was a problem uploading your image, please try again"
      redirect_to :back
    end
  end

  def set_up_invite
    @invite = token_invite(params[:invite_token])
    validate_and_create_site if @invite
  end

  def validate_and_create_site
    if @invite.email == @user.email
      UserSite.create(
        user_id: @user.id,
        site_id: @invite.site.id,
        admin: false
      )
    end
  end

  def set_up_new_conversation
    @conversation = Conversation.new
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
end
