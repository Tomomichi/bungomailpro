class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    redirect_to(mypage_path) if authenticated?

    @meta_title = 'アカウント登録'
    @no_index = true
  end

  def create
    user = User.find_or_initialize_by(email_address: user_params[:email])

    # すでに登録済みの場合はログイン画面へ
    if user.persisted?
      flash[:error] = 'このメールアドレスはすでに登録されています。登録情報を確認・更新したい場合はログインしてください。'
      redirect_to(new_session_path) and return
    end

    user.save
    user.generate_magic_login_token!

    BungoMailer.with(user: user).user_registered_email.deliver_now
    redirect_to(root_path, flash: { success: 'ユーザー登録が完了しました！ご登録内容の確認メールをお送りしています。もし10分以上経ってもメールが届かない場合は運営までお問い合わせください。' })
  end

  def show
    @meta_title = 'マイページ'
    @no_index = true
  end

  # 今のところプッシュ通知の更新にしか使ってない
  def update
    current_user.update_attribute!(:fcm_device_token, params[:token])
    head :ok
  end

  def destroy
    begin
      @user = User.find_by(email_address: params[:email])
      if @user.blank?
        flash[:error] = '入力されたメールアドレスで登録が確認できませんでした。入力内容をご確認いただき、それでも解決しない場合はお手数ですが運営までお問い合わせください。'
        redirect_to page_path(:unsubscribe) and return
      end

      # 有料ユーザーのときは処理をスキップして手動削除
      if @user.stripe_customer_id # paid_memberで判定すると、トライアル前の人も削除してstripeだけに残っちゃうので広く拾う
        logger.error "[Error] Paid account cancelled: #{@user.stripe_customer_id}"
      else
        @user.destroy
      end
      flash[:success] = '退会処理を完了しました。すべての課金とメール配信を停止します。これまでのご利用ありがとうございました。'
      redirect_to params[:redirect_to] || root_path
    rescue => e
      logger.error "[Error]Unsubscription failed: #{e.message}, #{params[:email]}"
      flash[:error] = '処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
      redirect_to page_path(:unsubscribe)
    end
  end

  def webpush_test
    Webpush.notify(webpush_payload)
  rescue
    flash[:error] = 'プッシュ通知のテスト送信に失敗しました。ブラウザの通知許可を再度ご設定ください。'
    redirect_to mypage_path
  end

  private

    def user_params
      params.require(:user).permit(:email)
    end

    def webpush_payload
      {
        message: {
          name: "プッシュ通知テスト",
          token: current_user.fcm_device_token,
          notification: {
            title: "プッシュ通知テスト",
            body: "ブンゴウメールのプッシュ通知テスト配信です。",
            image: "/favicon.ico",
          },
          webpush: {
            fcm_options: {
              link: mypage_url,
            },
          },
        }
      }
    end
end
