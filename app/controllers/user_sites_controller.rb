class UserSitesController < ApplicationController
  def destroy
    user_site = UserSite.find_by(id: params[:id])
    user_site_user = user_site.user

    user_site.delete ? flash[:notice] = "#{user_site_user.name} removed" : flash[:warn] = "Unable to remove #{user_site_user.name}, please try again"

    redirect_to :back
  end
end