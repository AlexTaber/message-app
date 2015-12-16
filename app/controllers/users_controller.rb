class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.valid?
      @user.save
      flash[:notice] = "User successfully created"
      session[:user_id] = @user.id
      redirect_to home_path
    else
      flash[:warn] = "Unable to create user, please try again"
      redirect_to :back
    end
  end

  def destroy
  end

  def home
    current_user.has_sites? ? find_user_site : @site = Site.new
  end

  private

  def user_by_id
    @user = User.find_by(id: params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :password, :email, :admin, :tier)
  end

  def find_user_site
    params[:site_id] ? @site = Site.find_by(id: params[:site_id]) : @site = current_user.sites.first
  end
end
