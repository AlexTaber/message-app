class SitesController < ApplicationController
  before_action :site_by_id, only: [:edit, :update, :add_users, :destroy]

  def new
    @site = Site.new
  end

  def create
    if current_user.can_create_site
      @site = Site.new(site_params)

      if @site.valid?
        @site.save
        set_up_user
        send_site_email
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
      flash[:notice] = "Site successfully saved" if set_up_users
      redirect_to home_path
    else
      flash[:warn] = "Unable to save updates to site, please try again"
      redirect_to :back
    end
  end

  def destroy
    if @site
      @site.delete
      flash[:notice] = "Site deleted"
    else
      flash[:warn] = "Unable to delete site, please try again"
    end

    redirect_to home_path
  end

  def add_users
  end

  private

  def site_by_id
    @site = Site.find_by(id: params[:id])
  end

  def site_params
    params.require(:site).permit(:name, :url, :active)
  end

  def set_up_users
    if params[:site][:user_ids]
      user_ids = params[:site][:user_ids].reject(&:empty?)
      user_ids.each do |user_id|
        if current_user.can_add_user_to_site(@site)
          userSite = @site.user_sites.find_by(user_id: user_id)
          unless userSite
            UserSite.create(
              user_id: user_id,
              site_id: @site.id,
              admin: false
            )

            send_added_to_site_email(User.find_by(id: user_id), @site, current_user)
            set_up_notification(user_id, @site)
          end
        else
          flash[:warn] = "You have reached the maximum number of users for this site. Please upgrade and try again"
          return false
        end
      end
    end

    return true
  end

  def set_up_user
    UserSite.create(
      user_id: current_user.id,
      site_id: @site.id,
      admin: true,
      approved: true
    )
  end

  def set_up_notification(user_id, site)
    Notification.create(
      user_id: user_id,
      content: "You have been added to the site #{@site.name} by #{current_user.name}"
    )
  end

  def send_site_email
    UserMailer.site_email(current_user, @site).deliver_now
  end

  def send_added_to_site_email(user, site, inviter)
    UserMailer.added_to_site_email(user, site, inviter).deliver_now
  end
end