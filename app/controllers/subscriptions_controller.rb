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

  def edit

  end

  def update
    if params[:tier_id]
      if params[:tier_id].to_i > 1
        if current_user.subscription.upgrade(params[:tier_id].to_i)
          current_user.update_attributes(tier_id: params[:tier_id])
          flash[:notice] = "Subscription successfully updated."
          redirect_to home_path
        else
          flash[:warn] = "Unable to process new subscription plan, please try again"
          redirect_to :back
        end
      else
        if current_user.subscription.cancel
          current_user.update_attributes(tier_id: params[:tier_id])
          flash[:notice] = "Your account has been set to the Basic tier"
          redirect_to home_path
        else
          flash[:warn] = "Unable to set tier to Basic, please try again"
          redirect_to :back
        end
      end
    else
      flash[:warn] = "Please enter the tier you with to change to"
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