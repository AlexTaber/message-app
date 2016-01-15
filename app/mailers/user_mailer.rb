class UserMailer < ApplicationMailer
  default from: 'admin@mercuryapp.co'

  def invite_email(invite)
    @url  = "http://localhost:3000/users/new?invite_token=#{invite.token}"
    @site = invite.site
    @user = invite.user
    mail(to: invite.email, subject: "You've just been invited!")
  end

  def site_email(user, site)
    @user = user
    @site = site
    mail(to: user.email, subject: "Here's Your Token for #{@site.name}")
  end

  def password_recovery_email(user, password_recovery)
    @user = user
    @password_recovery = password_recovery
    @url = "http://localhost:3000/password_recoveries/#{password_recovery.id}/check"
    mail(to: user.email, subject: "Password Recovery")
  end
end
