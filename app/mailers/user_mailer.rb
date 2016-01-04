class UserMailer < ApplicationMailer
  default from: 'noreply@mercury.com'

  def invite_email(email)
    @url  = 'localhost:3000'
    mail(to: email, subject: "You've just been invited!")
  end
end
