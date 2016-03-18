class SubscriptionsController < ApplicationController
  before_action :subscription_by_id, only: [:edit, :update]

  def new
    @subscription = Subscription.new
    @tier_id = 1
    @card_token = nil
  end

  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.save_with_payment(params[:tier_id].to_i)
      flash[:notice] = "Thank you for subscribing!"
      redirect_to new_project_path
    else
      flash[:warn] = "Unable to process subscription, please try again"
      redirect_to :back
    end
  end

  def edit
    @card_token = current_user.subscription.get_card_token
    @tier_id = current_user.tier.id
  end

  def update
    @subscription.assign_attributes(subscription_params)

    if @subscription.valid?
      if @subscription.upgrade(params[:tier_id].to_i)
        flash[:notice] = "Your tier has been updated!"
        redirect_to home_path
      else
        flash[:warn] = "Unable to process subscription, please try again"
        redirect_to :back
      end
    else
      flash[:warn] = "Unable to update subscription, please try again"
      redirect_to :back
    end
  end

  def destroy
  end

  private

  def subscription_params
    params.require(:subscription).permit(:stripe_card_token, :user_id)
  end

  def subscription_by_id
    @subscription = Subscription.find_by(id: params[:id])
  end
end