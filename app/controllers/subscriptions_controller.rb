class SubscriptionsController < ApplicationController
  def new
    @subscription = Subscription.new
    @tier_id = params[:tier_id]
  end

  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.save_with_payment(params[:tier_id].to_i)
      flash[:notice] = "Thank you for subscribing!"
      redirect_to home_path
    else
      flash[:warn] = "Unable to process subscription, please try again"
      redirect_to :back
    end
  end

  def destroy
  end

  private

  def subscription_params
    params.require(:subscription).permit(:stripe_card_token, :user_id)
  end
end