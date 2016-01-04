class RequestsController < ApplicationController
  def new
    @site = token_site(params[:token])
    @request = current_user.pending_request_by_site(@site) || Request.new
  end

  def create
    @request = Request.new(request_params)

    if @request.valid?
      @request.save
      flash[:notice] = "Request sent"
    else
      flash[:warn] = "Unable to send request, please try again"
    end

    redirect_to :back
  end

  private

  def request_params
    params.require(:request).permit(:user_id, :receiver_id, :site_id)
  end
end
