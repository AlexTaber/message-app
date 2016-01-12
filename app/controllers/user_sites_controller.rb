class UserSitesController < ApplicationController
  before_action :user_site_by_id, only: [:update, :destroy]

  def update
    @user_site.assign_attributes(user_site_params)

    if @user_site.valid?
      @user_site.save
      flash[:notice] = "Successfully updated user #{@user_site.user.name}"
    else
      flash[:warn] = "Unable to update user, please try again"
    end

    redirect_to :back
  end

  def destroy
    @user_site = UserSite.find_by(id: params[:id])

    @user_site.delete ? flash[:notice] = "#{@user_site.user.name} removed" : flash[:warn] = "Unable to remove #{@user_site.user.name}, please try again"

    redirect_to :back
  end

  private

  def user_site_by_id
    @user_site = UserSite.find_by(id: params[:id])
  end

  def user_site_params
    params.require(:user_site).permit(:user_id, :site_id, :admin)
  end
end