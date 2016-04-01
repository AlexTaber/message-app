class BansController < ApplicationController
  before_action :require_owner, only: [:create, :update]
  def new
    @user = User.find_by(id: params[:user_id])
    @ban = Ban.new
  end

  def create
    @ban = Ban.new(ban_params)
    @ban.update_attributes(expiration: Date.today + 2.weeks) unless @ban.expiration

    if @ban.valid?
      @ban.save
      flash[:notice] = "#{@ban.user.name} has been successfully banned"
    else
      flash[:warn] = "Unable to process ban, please try again"
    end

    redirect_to :back
  end

  def update
    @ban = Ban.find_by(id: params[:id])
    @ban.assign_attributes(ban_params)

    if @ban.valid?
      @ban.save
      flash[:notice] = "#{@ban.user.name}'s ban has been updated"
    else
      flash[:warn] = "Unable to update ban, please try again"
    end

    redirect_to :back
  end

  private

  def ban_params
    params.require(:ban).permit(:user_id, :active, :expiration, :message)
  end
end