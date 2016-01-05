class SitesController < ApplicationController
  before_action :site_by_id, only: [:edit, :update, :add_users]
  def new
    @site = Site.new
  end

  def create
    if current_user.can_create_site
      @site = Site.new(site_params)

      if @site.valid?
        @site.save
        set_up_user
        flash[:notice] = "Site successfully created"
        redirect_to home_path(site_id: @site.id)
      else
        flash[:warn] = "Unable to create site, please try again"
        redirect_to :back
      end
    else
      flash[:warn] = "You've reached the site limit for your current tier of service. Please upgrade and try again."
      redirect_to :back
    end
  end

  def edit

  end

  def update
    @site.assign_attributes(site_params)

    if @site.valid?
      @site.save
      set_up_users
      flash[:notice] = "Site successfully saved"
      redirect_to home_path(site_id: @site.id)
    else
      flash[:warn] = "Unable to save updates to site, please try again"
      redirect_to :back
    end
  end

  def destroy
  end

  def add_users
  end

  private

  def site_by_id
    @site = Site.find_by(id: params[:id])
  end

  def site_params
    params.require(:site).permit(:name, :url)
  end

  def set_up_users
    user_ids = params[:site][:user_ids].reject!(&:empty?)
    user_ids.each do |user_id|
      userSite = @site.user_sites.find_by(user_id: user_id)
      unless userSite
        UserSite.create(
          user_id: user_id,
          site_id: @site.id,
          admin: false
        )

        set_up_notification(user_id, @site)
      end
    end
  end

  def set_up_user
    UserSite.create(
      user_id: current_user.id,
      site_id: @site.id,
      admin: true
    )
  end

  def set_up_notification(user_id, site)
    Notification.create(
      user_id: user_id,
      content: "You have been added to the site #{@site.name} by #{current_user.name}"
    )
  end
end