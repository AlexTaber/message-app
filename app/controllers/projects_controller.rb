class ProjectsController < ApplicationController
  before_action :project_by_id, only: [:edit, :update, :add_users, :destroy, :project_owner_data]

  def new
    @project = Project.new
  end

  def create
    if current_user.can_create_project
      @project = Project.new(project_params)

      if @project.valid?
        @project.save
        set_up_user
        send_project_email
        flash[:notice] = "Project successfully created"
        redirect_to home_path(project_id: @project.id)
      else
        flash[:warn] = "Unable to create project, please try again"
        redirect_to :back
      end
    else
      flash[:warn] = "You've reached the project limit for your current tier of service. Please upgrade and try again."
      redirect_to :back
    end
  end

  def edit

  end

  def update
    @project.assign_attributes(project_params)

    if @project.valid?
      @project.save
      flash[:notice] = "Project successfully saved"

      redirect_to home_path(project_id: @project.id)
    else
      flash[:warn] = "Unable to save updates to project, please try again"
      redirect_to :back
    end
  end

  def destroy
    if @project
      @project.delete
      flash[:notice] = "Project deleted"
    else
      flash[:warn] = "Unable to delete project, please try again"
    end

    redirect_to home_path
  end

  def add_users
  end

  def projects_data
    @projects = Project.all.order(id: :desc)
  end

  def project_owner_data

  end

  private

  def project_by_id
    @project = Project.find_by(id: params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :url, :active)
  end

  def set_up_user
    UserProject.create(
      user_id: current_user.id,
      project_id: @project.id,
      admin: true,
      approved: true
    )
  end

  def set_up_notification(user_id, project)
    Notification.create(
      user_id: user_id,
      content: "You have been added to the project #{@project.name} by #{current_user.name}"
    )
  end

  def send_project_email
    UserMailer.project_email(current_user, @project).deliver_now
  end
end