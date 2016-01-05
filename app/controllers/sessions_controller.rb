class SessionsController < ApplicationController

  def new
    if current_user
      redirect_to home_path
    end
    @user = User.new
  end

  def create

    @user = User.find_by(email: params[:email])

    if @user && @user.authenticate(params[:password])
      cookies.permanent.signed[:user_id] = @user.id
      if params[:token]
        redirect_to message_box_path(token: params[:token])
      else
        redirect_to home_path
      end
    else
      flash[:warn] = "Invalid email or password. Please try again."
      if params[:token]
        redirect_to message_box_path(token: params[:token])
      else
        redirect_to home_path
      end
    end

  end

  def destroy
    cookies.signed[:user_id] = nil
    if params[:message_box]
      redirect_to mb_login_path(token: params[:token])
    else
      redirect_to root_path
    end
  end

  def mb_new
    @token = params[:token]
  end
end