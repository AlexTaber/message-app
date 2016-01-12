class UserMailer < ApplicationMailer
  default from: 'info@peekskillwebdesign.com'

  def invite_email(invite)
    @url  = "https://www.mercuryapp.co/users/new?invite_token=#{invite.token}"
    @site = invite.site
    @user = invite.user
    mail(to: invite.email, subject: "You've just been invited!")
  end

  def site_email(user, site)
    @user = user
    @site = site
    mail(to: user.email, subject: "Here's Your Token for #{@site.name}")
  end
end
