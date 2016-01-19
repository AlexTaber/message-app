class UserMailer < ApplicationMailer
  default from: "Mercury App <no-reply@mercuryapp.co>"

  def welcome_email(user)
    @url = "http://localhost:3000/home"
    @user = user
    mail(to: user.email, subject: "Thank You for Joining MercuryApp", from: "MercuryApp <admin@mercuryapp.co>")
  end

  def added_to_site_email(user, site, inviter)
    @site = site
    @user = user
    @inviter = inviter
    @url = "http://localhost:3000/home/?site_id=#{@site.id}"
    mail(to: user.email, subject: "You've Been Added to #{site.name}", from: "MercuryApp <admin@mercuryapp.co>")
  end

  def invite_email(invite)
    @url  = "http://localhost:3000/users/new?invite_token=#{invite.token}"
    @site = invite.site
    @user = invite.user
    mail(to: invite.email, subject: "You've just been invited!", from: "Mercury Invite <admin@mercuryapp.co>")
  end

  def site_email(user, site)
    @user = user
    @site = site
    mail(to: user.email, subject: "Here's Your Token for #{@site.name}", from: "MercuryApp <admin@mercuryapp.co>")
  end

  def password_recovery_email(user, password_recovery)
    @user = user
    @password_recovery = password_recovery
    @url = "http://localhost:3000/password_recoveries/#{password_recovery.id}/check"
    mail(to: user.email, subject: "Password Recovery", from: "Mercury Password Recovery <no-reply@mercuryapp.co>")
  end

  def monthly_email(user)
    @user = user
    mail(to: user.email, subject: "Monthly Newsletter from MercuryApp", from: "MercuryApp Newsletter <no-reply@mercuryapp.co>")
  end
end
