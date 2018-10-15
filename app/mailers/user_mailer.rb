class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.magic_login_email.subject
  #
  def magic_login_email(user)
    @user = User.find user.id
    @url  = URI.join(root_url, "auth?token=#{@user.magic_login_token}")

    mail(to: @user.email, subject: "Magic Login")
  end


  def deliver_chapter(delivery)
    @user = delivery.user_course.user
    @chapter = delivery.chapter

    mail(to: @user.email, subject: 'ほげ')
  end
end
