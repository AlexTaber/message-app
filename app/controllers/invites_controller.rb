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
      flash[:notice] = "Invite sent to #{@invite.email}"
    elsif @invite.existing_user
      create_user_project
      flash[:notice] = "#{@invite.existing_user.name} was added!"
    else
      flash[:warn] = "Unable to send invite, please try again"
    end

    if request.xhr?
      render partial: 'users/manage_users', locals: { user: current_user, project: @invite.project, invite: Invite.new, invite_notice: flash[:notice] }
    else
      redirect_to home_path(project_id: @invite.project.id)
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:user_id, :project_id, :email)
  end

  def send_invite_email
    UserMailer.invite_email(@invite).deliver_now
  end

  def create_user_project
    UserProject.create(
      user_id: @invite.existing_user.id,
      project_id: @invite.project.id,
      admin: false
    )
  end
end