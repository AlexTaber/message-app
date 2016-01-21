class PasswordRecoveriesController < ApplicationController
  before_action :password_recovery_by_id, only: [:check, :verify]

  def new
    @password_recovery = PasswordRecovery.new
  end

  def create
    @user = User.find_by(email: params[:email])
    @password_recovery = PasswordRecovery.new(user_id: @user.id)

    if @password_recovery.valid?
      @user.invalidate_password_recoveries
      @password_recovery.save
      send_password_recovery_email
      flash[:notice] = "Password recovery email sent to #{@password_recovery.user.email}"
      redirect_to root_path
    else
      flash[:warn] = "Unable to initiate password recovery, please try again"
      redirect_to :back
    end
  end

  def check
    unless @password_recovery.active
      flash[:warn] = "This url is inactive"
      redirect_to root_path
    end

    @token = params[:token]
  end

  def verify
    if @password_recovery
      if params[:token] == @password_recovery.token
        if params[:confirm_password] == params[:password]
          @password_recovery.user.update_attribute(:password, params[:password])
          @password_recovery.update_attribute(:active, false)
          cookies.permanent.signed[:user_id] = @password_recovery.user.id
          redirect_to home_path
        else
          flash[:warn] = "Password/Confirm Password fields do not match, please try again"
          redirect_to :back
        end
      else
        flash[:warn] = "Your Token is Invalid"
        redirect_to :back
      end
    else
      flash[:warn] = "Invalid URL"
      redirect_to root_path
    end
  end

  private

  def password_recovery_params
    params.require(:password_recovery).permit(:user_id)
  end

  def password_recovery_by_id
    @password_recovery = PasswordRecovery.find_by(id: params[:id])
  end

  def send_password_recovery_email
    UserMailer.password_recovery_email(@user, @password_recovery).deliver_now
  end
end