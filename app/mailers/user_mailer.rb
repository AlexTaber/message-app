class UserMailer < ApplicationMailer
  default from: 'info@peekskillwebdesign.com'

  def invite_email(email, site)
    @url  = 'localhost:3000'
    mail(to: email, subject: "You've just been invited!")
  end
end
