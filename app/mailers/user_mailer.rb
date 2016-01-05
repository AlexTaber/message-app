class UserMailer < ApplicationMailer
  default from: 'info@peekskillwebdesign.com'

  def invite_email(invite)
    @url  = "http://localhost:3000/users/new?invite_token=#{invite.token}"
    @site = invite.site
    @user = invite.user
    mail(to: invite.email, subject: "You've just been invited!")
  end
end
