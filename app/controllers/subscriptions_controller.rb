class SubscriptionsController < ApplicationController
  def index
    @meta_title = "配信管理"

    if params[:finished].present?
      @campaigns = current_user.created_or_subscribing_campaigns.finished.order(start_date: :asc).page(params[:page])
    else
      @campaigns = current_user.created_or_subscribing_campaigns.upcoming.order(start_date: :asc).page(params[:page])
    end
  end

  def create
    subscription = current_user.subscriptions.new(subscription_params)

    if subscription.save
      flash[:success] = '配信の購読が完了しました！'
      redirect_to campaign_path(subscription.campaign_id)
    else
      flash[:error] = subscription.errors.full_messages.join('. ')
      redirect_to campaign_path(subscription.campaign_id), status: 422
    end
  end

  def destroy
    subscription = authorize Subscription.find(params[:id])
    subscription.destroy!
    redirect_to campaign_path(subscription.campaign), flash: { success: "配信の購読を解除しました。" }, status: 303
  end

  private

    def subscription_params
      params.require(:subscription).permit(:campaign_id, :delivery_method)
    end
end
