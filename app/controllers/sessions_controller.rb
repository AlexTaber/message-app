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
      session[:user_id] = @user.id
      redirect_to home_path
    else
      flash[:warn] = "Invalid email or password. Please try again."
      redirect_to '/login'
    end

  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end