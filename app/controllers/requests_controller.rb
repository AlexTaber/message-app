class RequestsController < ApplicationController
  def new
    @site = token_site(params[:token])
    @request = current_user.pending_request_by_site(@site) || Request.new
  end

  def create
    @request = Request.new(request_params)

    if current_user.can_send_request(@request)
      @request.save
      flash[:notice] = "Request sent"
    else
      flash[:warn] = "Unable to send request, please try again"
    end

    redirect_to :back
  end

  def update
    @request = Request.find_by(id: params[:id])
    @request.assign_attributes(request_params)

    if @request.valid?
      @request.save
      set_up_user if params[:request][:approved]
      flash[:notice] = "Request updated"
    else
      flash[:warn] = "Unable to update request, please try again"
    end

    redirect_to :back
  end

  private

  def request_params
    params.require(:request).permit(:user_id, :site_id, :active)
  end

  def set_up_user
    UserSite.create(
      user_id: @request.user.id,
      site_id: @request.site.id,
      admin: false
    )
  end
end
