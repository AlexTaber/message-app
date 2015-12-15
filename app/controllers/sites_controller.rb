class SitesController < ApplicationController
  def new
    @site = Site.new
  end

  def create
    @site = Site.new(site_params)

    if @site.valid?
      @site.save
      set_up_user
      flash[:notice] = "Site successfully created"
      redirect_to home_path
    else
      flash[:warn] = "Unable to create site, please try again"
      redirect_to :back
    end
  end

  def destroy
  end

  private

  def site_params
    params.require(:site).permit(:name, :url)
  end

  def set_up_user
    @user = User.find_by(id: params[:site][:user_id])
    UserSite.create(user_id: @user.id, site_id: @site.id)
  end
end