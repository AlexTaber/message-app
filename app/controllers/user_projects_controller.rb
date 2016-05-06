class UserProjectsController < ApplicationController
  before_action :user_project_by_id, only: [:update, :destroy]

  def update
    params[:user_project][:approved] = params[:user_project][:approved] if params[:user_project][:approved]
    @user_project.assign_attributes(user_project_params)

    if @user_project.valid?
      if params[:user_project][:admin] && @user_project.not_allowed?
        flash[:warn]  = "#{@user_project.user.name} has reached their tier limit"
      else
        @user_project.save
        flash[:notice] = "Successfully updated user #{@user_project.user.name}"
      end
    else
      flash[:warn] = "Unable to update user, please try again"
    end

    redirect_to :back
  end

  def destroy
    @user_project = UserProject.find_by(id: params[:id])
    project = @user_project.project

    @user_project.delete ? flash[:notice] = "#{@user_project.user.name} removed" : flash[:warn] = "Unable to remove #{@user_project.user.name}, please try again"

    if request.xhr?
      render partial: 'users/manage_users', locals: { user: current_user, project: project, invite: Invite.new, invite_notice: "#{@user_project.user.name} removed" }
    else
      redirect_to :back
    end
  end

  private

  def user_project_by_id
    @user_project = UserProject.find_by(id: params[:id])
  end

  def user_project_params
    params.require(:user_project).permit(:user_id, :project_id, :admin, :approved)
  end
end