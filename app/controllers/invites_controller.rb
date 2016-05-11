class InvitesController < ApplicationController
  def new
    @invite = Invite.new
  end

  def create
    @invite = Invite.new(invite_params)
    @invite.assign_attributes(email: @invite.email.downcase)
    existing_user = @invite.existing_user

    if @invite.can_be_sent?
      @invite.save
      send_invite_email
      flash[:notice] = "We have sent an email to #{@invite.email} inviting them to join #{@invite.project.name}!\n\nWhen they sign up, they will be automatically added to your project!"
    elsif existing_user
      if existing_user.is_member_of_project?(@invite.project)
        flash[:notice] = "#{existing_user.name} is already a member of #{@invite.project.name}"
      elsif current_user.tier.permit_project_user(@invite.project)
        create_user_project(existing_user)
        flash[:notice] = "#{existing_user.name} was added!"
      else
        flash[:warn] = "You have reached the maximum number of users for this project. Please upgrade to add more!"
      end
    else
      flash[:notice] = "Unable to send invite, please try again"
    end

    if request.xhr?
      render partial: 'users/manage_users', locals: { user: current_user, project: @invite.project, invite: Invite.new, invite_notice: flash[:notice] }
    else
      redirect_to home_path(project_id: @invite.project.id)
    end
  end

  def destroy
    @invite = Invite.find_by(id: params[:id])

    if @invite.delete
      flash[:notice] = "Invite deleted"
    else
      flash[:warn] = "Unable to delete invite, please try again"
    end

    if request.xhr?
      render partial: 'users/manage_users', locals: { user: current_user, project: @invite.project, invite: Invite.new, invite_notice: flash[:notice] }
    else
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

  def send_added_to_project_email(user, project, inviter)
    UserMailer.added_to_project_email(user, project, inviter).deliver_now
  end

  def create_user_project(existing_user)
    UserProject.create(
      user_id: existing_user.id,
      project_id: @invite.project.id,
      admin: false
    )

    send_added_to_project_email(existing_user, @invite.project, @invite.user)
  end
end