class BansController < ApplicationController
  def create
    @ban = Ban.new(ban_params)

    if @ban.valid?
      flash[:notice] = "#{@ban.user.name} has been successfully banned"
    else
      flash[:warn] = "Unable to process ban, please try again"
    end

    redirect_to :back
  end

  private

  def ban_params
    params.require(:ban).permit(:user_id, :active, :expiration, :message)
  end
end