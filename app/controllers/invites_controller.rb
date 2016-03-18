class InvitesController < ApplicationController
  def new
    @invite = Invite.new
  end

  def create
    @invite = Invite.new(invite_params)
    @invite.assign_attributes(email: @invite.email.downcase)

    if @invite.can_be_sent?
      @invite.save
      send_invite_email
      flash[:notice] = "Invite sent!"
      redirect_to home_path
    else
      flash[:warn] = "Unable to send invite, please try again"
      redirect_to :back
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:user_id, :project_id, :email)
  end

  def send_invite_email
    UserMailer.invite_email(@invite).deliver_now
  end
end