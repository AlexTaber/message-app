class SessionsController < ApplicationController

  def new
    if current_user
      redirect_to home_path
    end
    @user = User.new
  end

  def create
    params[:email].downcase!
    @user = User.find_by(email: params[:email])

    if @user && @user.authenticate(params[:password])
      cookies.permanent.signed[:user_id] = @user.id
      if params[:mb].to_b
        redirect_to message_box_path
      else
        redirect_to home_path
      end
    else
      flash[:warn] = "Invalid email or password. Please try again."
      redirect_to :back
    end

  end

  def destroy
    cookies.signed[:user_id] = nil
    session[:project_id] = nil
    if params[:message_box]
      redirect_to mb_login_path(token: params[:token])
    else
      redirect_to root_path
    end
  end

  def splash

  end

  def mb_new
    @token = params[:token]
  end
end