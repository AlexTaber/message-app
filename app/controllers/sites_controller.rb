class SitesController < ApplicationController
  def new
    @site = Site.new
  end

  def create
    @site = Site.new(site_params)

    if @site.valid?
      @site.save
      set_up_users
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

  def set_up_users
    user_ids = params[:site][:user_ids].reject!(&:empty?)
    user_ids.each do |user_id|
      UserSite.create(
        user_id: user_id,
        site_id: @site.id,
        admin: false
      )
    end
      UserSite.create(
        user_id: current_user.id,
        site_id: @site.id,
        admin: true
      )
  end
end