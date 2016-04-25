class UserMailer < ApplicationMailer
  default from: "Mercury App <no-reply@mercuryapp.co>"

  def welcome_email(user)
    @url = "http://localhost:3000/home"
    @user = user
    mail(to: user.email, subject: "Thank You for Joining MercuryApp", from: "MercuryApp <admin@mercuryapp.co>")
  end

  def added_to_project_email(user, project, inviter)
    @project = project
    @user = user
    @inviter = inviter
    @url = "http://localhost:3000/home/?project_id=#{@project.id}"
    mail(to: user.email, subject: "You've Been Added to #{project.name}", from: "MercuryApp <admin@mercuryapp.co>")
  end

  def invite_email(invite)
    @url  = "http://localhost:3000/users/new?invite_token=#{invite.token}"
    @project = invite.project
    @user = invite.user
    mail(to: invite.email, subject: "#{@user.name} has invited you to join #{@project.name} on MercuryApp", from: "Mercury Invite <admin@mercuryapp.co>")
  end

  def project_email(user, project)
    @user = user
    @project = project
    mail(to: user.email, subject: "Thank You for Adding a New Project", from: "MercuryApp <admin@mercuryapp.co>")
  end

  def password_recovery_email(user, password_recovery)
    @user = user
    @password_recovery = password_recovery
    @url = "http://localhost:3000/password_recoveries/#{password_recovery.id}/check?token=#{password_recovery.token}"
    mail(to: user.email, subject: "Password Recovery", from: "Mercury Password Recovery <no-reply@mercuryapp.co>")
  end

  def monthly_email(user)
    @user = user
    mail(to: user.email, subject: "Monthly Newsletter from MercuryApp", from: "MercuryApp Newsletter <no-reply@mercuryapp.co>")
  end

  def new_message_email(message, user)
    @url = "#{home_url(tasks: nil, user_ids: message.conversation.user_ids, project_id: message.conversation.project.id)}"
    @message = message
    @user = user
    @project = message.conversation.project
    mail(to: user.email, subject: "New Message from #{message.user.name}", from: "MercuryApp <no-reply@mercuryapp.co>")
  end

  def new_task_email(task, user)
    @url = home_url(tasks: true, user_ids: task.message.conversation.user_ids, project_id: task.message.conversation.project.id)
    @task = task
    @user = user
    @tasker = @task.message.user
    @project = task.message.conversation.project
    mail(to: user.email, subject: "New Task on #{@project.name}", from: "MercuryApp <no-reply@mercuryapp.co>")
  end

  def completed_task_email(task, user)
    @url = home_url(tasks: true, user_ids: task.message.conversation.user_ids, project_id: task.message.conversation.project.id)
    @task = task
    @user = user
    @project = task.message.conversation.project
    mail(to: user.email, subject: "Completed Task on #{@project.name}", from: "MercuryApp <no-reply@mercuryapp.co>")
  end
end
