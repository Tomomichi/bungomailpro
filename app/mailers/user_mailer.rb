class UserMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.magic_login_email.subject
  #
  def magic_login_email(user)
    @user = User.find user.id
    @url  = URI.join(root_url, "auth?token=#{@user.magic_login_token}")

    xsmtp_api_params = { category: 'login' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(to: @user.email, subject: '【ブンゴウメール】ログイン用URL')
    logger.info "[LOGIN] Login mail sent to #{@user.id}"
  end

  def chapter_email
    @subscription = params[:subscription]
    @notification = Notification.find_by(date: Time.current)
    @comment = @subscription.current_comment
    send_at = Time.zone.parse(@subscription.next_delivery_date.to_s).change(hour: @subscription.delivery_hour)

    # 配信が明日以降なら処理をスキップ（過去日時指定は許可。その場合SendGridの仕様で即時配信される）
    return if send_at > Time.zone.today.end_of_day
    # 実際の配信先（PROプランのユーザー）がいない場合は処理をスキップ
    return if (deliverable_emails = @subscription.deliverable_emails).blank?

    xsmtp_api_params = {
      send_at: send_at.to_i,
      to: deliverable_emails,
      category: 'chapter'
    }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(
      from: "#{@subscription.current_book.author.tr(',', '、')}（ブンゴウメール） <bungomail@notsobad.jp>",
      to: 'noreplya@notsobad.jp', # xsmtpパラメータで上書きされるのでこのtoはダミー
      subject: "#{@subscription.current_book.title}（#{@subscription.next_chapter.index}/#{@subscription.current_book.chapters_count}）【#{@subscription.channel.title}】"
    )
    logger.info "[SCHEDULED] channel:#{@subscription.channel.id}, chapter:#{@subscription.next_chapter.book_id}-#{@subscription.next_chapter.index}, send_at:#{send_at}, to:#{@subscription.user_id}"
  end
end
