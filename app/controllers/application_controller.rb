class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :require_current_user

  def require_current_user
    unless current_user
      flash.now[:warn] = "You must be logged in to perform that action"
      redirect_to home_path
    end
  end

  def current_user
    @current_user ||= User.find(cookies.signed[:user_id]) if cookies.signed[:user_id]
  end

  def token_site(token)
    Site.find_by(token: token)
  end

  def token_invite(token)
    Invite.find_by(token: token)
  end

  def token_conversation(token)
    Conversation.find_by(token: token)
  end

  def default_url_options
    if Rails.env.production?
      {:host => "mercuryapp.co"}
    else
      {}
    end
  end
end
