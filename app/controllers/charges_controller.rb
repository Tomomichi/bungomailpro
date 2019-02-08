class ChargesController < ApplicationController
  before_action :require_login
  before_action :set_charge
  after_action :verify_authorized

  def new
    @breadcrumbs << { name: 'アカウント情報', url: user_path(current_user.token) }
    @breadcrumbs << { name: '決済情報' }
  end

  def create
    # Stripe::Customerが登録されてなかったら新規登録、されてればクレカ情報更新（解約→再登録のケース）
    charge = Charge.find_or_initialize_by(user_id: current_user.id)
    charge.create_or_update_customer(params)

    # 定期課金開始
    charge.create_subscription

    flash[:success] = '決済登録が完了しました🎉 1ヶ月の無料トライアル期間のあとに、支払いが開始します'
    redirect_to user_path(current_user.token)
  rescue Stripe::StripeError => e
    logger.error "[STRIPE] user: #{current_user.id}, error: #{e}"
    flash[:error] = '決済情報の登録に失敗しました...。カード情報を再度ご確認のうえ、しばらく経ってからもう一度お試しください。どうしてもうまくいかない場合は運営までお問い合わせください。'
    redirect_to new_charge_path
  end

  def edit
    @breadcrumbs << { name: 'アカウント情報', url: user_path(current_user.token) }
    @breadcrumbs << { name: '決済情報の更新' }
  end

  def update
    @charge.update_customer(params)

    flash[:success] = 'カード情報を更新しました🎉 次回の支払いから変更が適用されます。'
    redirect_to user_path(current_user.token)
  rescue Stripe::StripeError => e
    logger.error "[STRIPE] user: #{current_user.id}, error: #{e}"
    flash[:error] = 'カード情報の更新に失敗しました...。カード情報を再度ご確認のうえ、しばらく経ってからもう一度お試しください。どうしてもうまくいかない場合は運営までお問い合わせください。'
    redirect_to edit_charge_path(@charge)
  end

  def destroy
    flash[:info] = '解約処理を完了しました。これ以降の支払いは一切行われません。ご利用ありがとうございました。'
    flash[:info] += 'メール配信は現在の期間終了まで継続したあと、自動的に停止します。すぐに配信も停止したい場合は、チャネルの購読を解除してください。' if @charge.status != 'past_due'
    @charge.cancel_subscription
    redirect_to user_path(current_user.token)
  rescue Stripe::StripeError => e
    logger.error "[STRIPE] user: #{current_user.id}, error: #{e}"
    flash[:error] = '決済登録の解除に失敗しました...。画面をリロードして、しばらく経ってからもう一度お試しください。どうしてもうまくいかない場合は運営までお問い合わせください。'
    redirect_to user_path(current_user.token)
  end

  # 解約予約したのを再度アクティベイト
  def activate
    @charge.activate

    flash[:info] = '解約を取り消しました。次回決済日から通常どおり支払いが行われます。'
    redirect_to user_path(current_user.token)
  rescue Stripe::StripeError => e
    logger.error "[STRIPE] user: #{current_user.id}, error: #{e}"
    flash[:error] = '解約の取り消しに失敗しました...。画面をリロードして、しばらく経ってからもう一度お試しください。どうしてもうまくいかない場合は運営までお問い合わせください。'
    redirect_to user_path(current_user.token)
  end

  # Stripe自動送信メール用の支払い情報更新リンク: charges#editにリダイレクトする
  ## chargeが存在しない場合はpolicyで弾かれる
  def update_payment
    redirect_to edit_charge_path(current_user.charge)
  end

  private

  def set_charge
    if (id = params[:id])
      @charge = Charge.find(id)
      authorize @charge
    else
      authorize Charge
    end
  end
end
