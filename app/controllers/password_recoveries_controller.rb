class PasswordRecoveriesController < ApplicationController
  before_action :password_recovery_by_id, only[:check, :verify]

  def new
    @password_recovery = PasswordRecovery.new
  end

  def create
    @password_recovery = PasswordRecovery.new(password_recovery_params)

    if @password_recovery.valid?
      @password_recovery.save
      flash[:notice] = "Password recovery email sent to #{@password_recovery.user.email}"
      redirect_to root_path
    else
      flash[:warn] = "Unable to initiate password recovery, please try again"
      redirect_to :back
    end
  end

  def check

  end

  def verify
    if @password_recovery
      @password_recovery.user.update_attribute(:password, params[:password]) if params[:token] = @password_recovery.token
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
end