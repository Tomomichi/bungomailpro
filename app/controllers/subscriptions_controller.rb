class SubscriptionsController < ApplicationController
  before_action :require_login, only: [:create, :destroy]

  def create
    subscription = current_user.subscriptions.new(subscription_params)

    if subscription.save
      flash[:success] = '配信の購読が完了しました！'
      redirect_to book_assignment_path(subscription.book_assignment_id)
    else
      flash[:error] = subscription.errors.full_messages.join('. ')
      redirect_to book_assignment_path(subscription.book_assignment_id), status: 422
    end
  end

  def destroy
    subscription = authorize Subscription.find(params[:id])
    subscription.destroy!
    redirect_to book_assignment_path(subscription.book_assignment), flash: { success: "配信の購読を解除しました。" }, status: 303
  end

  private

    def subscription_params
      params.require(:subscription).permit(:book_assignment_id, :delivery_method)
    end
end
