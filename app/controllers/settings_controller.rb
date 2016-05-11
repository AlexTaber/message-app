class SettingsController < ApplicationController
  def update
    params[:setting][:email_notifications] = params[:setting][:email_notifications].to_b if params[:setting][:email_notifications]
    @setting = Setting.find_by(id: params[:id])
    @setting.assign_attributes(setting_params)

    if @setting.save
      flash[:notice] = "Settings successfully saved!"
    else
      flash[:warn] = "Unable to update your settings, please try again"
    end

    redirect_to :back
  end

  private

  def setting_params
    params.require(:setting).permit(:inactive_time, :email_notifications)
  end
end