class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  helper_method :current_user, :require_current_user, :owner_user, :display_analytics?

  def require_current_user
    unless current_user
      redirect_to splash_path
    end
  end

  def require_permitted_user
    if current_user && current_user.current_ban
      flash[:warn] = current_user.current_ban.message
      redirect_to splash_path
    end
  end

  def require_owner
    unless owner_user
      flash[:warn] = "You do not have permission to view this page"
      redirect_to home_path
    end
  end

  def current_user
    @current_user ||= User.find(cookies.signed[:user_id]) if cookies.signed[:user_id]
  end

  def owner_user
    current_user ? current_user.owner : false
  end

  def display_analytics?
    Rails.env.production? && !owner_user
  end

  def token_project(token)
    Project.find_by(token: token)
  end

  def token_invite(token)
    Invite.find_by(token: token)
  end

  def token_conversation(token)
    Conversation.find_by(token: token)
  end

  def default_url_options
    if Rails.env.production?
      {:host => "eviaonline.io"}
    else
      {}
    end
  end

  def is_true?(string)
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(string)
  end
end
