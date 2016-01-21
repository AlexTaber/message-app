class Subscription < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true

  attr_accessor :stripe_card_token

  def save_with_payment(tier_id)
    if valid?
      customer = Stripe::Customer.create(description: user.email, plan: tier_id - 1, card: stripe_card_token)
      self.stripe_customer_token = customer.id
      self.stripe_subscription_token = customer.subscriptions.first.id
      save!
      user.update_attribute(:tier_id, tier_id)
    end
  rescue Stripe::InvalidRequestError => e
    user.update_attribute(:tier_id, 1)
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end

  def upgrade(tier_id)
    customer = Stripe::Customer.retrieve(stripe_customer_token)
    subscription = customer.subscriptions.retrieve(stripe_subscription_token)
    subscription.plan = tier_id - 1
    subscription.save
    self.stripe_subscription_token = subscription.id

  rescue Stripe::InvalidRequestError => e
    user.update_attribute(:tier_id, 1)
    logger.error "Stripe error while updating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end

  def cancel
    customer = Stripe::Customer.retrieve(stripe_customer_token)
    subscription = customer.subscriptions.retrieve(stripe_subscription_token).delete(true)
    self.stripe_subscription_token = nil
  rescue Stripe::InvalidRequestError => e
    user.update_attribute(:tier_id, 1)
    logger.error "Stripe error while updating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end
end