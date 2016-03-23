class UserProjectsController < ApplicationController
  before_action :user_project_by_id, only: [:update, :destroy]

  def update
    params[:user_project][:approved] = params[:user_project][:approved] if params[:user_project][:approved]
    @user_project.assign_attributes(user_project_params)

    if @user_project.valid_and_allowed?
      @user_project.save
      flash[:notice] = "Successfully updated user #{@user_project.user.name}"
    else
      if @user_project.valid?
        flash[:warn]  = "#{@user_project.user.name} has reached their tier limit"
      else
        flash[:warn] = "Unable to update user, please try again"
      end
    end

    redirect_to :back
  end

  def destroy
    @user_project = UserProject.find_by(id: params[:id])

    @user_project.delete ? flash[:notice] = "#{@user_project.user.name} removed" : flash[:warn] = "Unable to remove #{@user_project.user.name}, please try again"

    redirect_to :back
  end

  private

  def user_project_by_id
    @user_project = UserProject.find_by(id: params[:id])
  end

  def user_project_params
    params.require(:user_project).permit(:user_id, :project_id, :admin, :approved)
  end
end