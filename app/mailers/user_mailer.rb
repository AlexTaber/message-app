class UserMailer < ApplicationMailer
  default from: 'info@peekskillwebdesign.com'

  def invite_email(email, site, user)
    @url  = 'http://localhost:3000'
    @site = site
    @user = user
    mail(to: email, subject: "You've just been invited!")
  end
end
