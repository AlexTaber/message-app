class RequestsController < ApplicationController
  def new
    @request = Request.new
    @site = token_site(params[:token])
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
