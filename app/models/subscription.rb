class Subscription < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true

  attr_accessor :stripe_card_token

  def get_card_token
    customer = Stripe::Customer.retrieve(stripe_customer_token)
    customer.default_source
  end

  def needs_card_token(tier)
    !get_card_token && tier.id != 1
  end

  def save_with_payment(tier, yearly)
    if valid?
      customer = create_customer_by_tier(tier, yearly)
      self.stripe_customer_token = customer.id
      self.stripe_subscription_token = customer.subscriptions.first.id
      save!
      user.update_attribute(:tier_id, tier.id)
    end
  rescue Stripe::InvalidRequestError => e
    user.update_attribute(:tier_id, 1)
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end

  def upgrade(tier, yearly)
    customer = Stripe::Customer.retrieve(stripe_customer_token)
    customer.sources.create({ source: stripe_card_token }) if needs_card_token(tier)
    subscription = customer.subscriptions.retrieve(stripe_subscription_token)
    subscription.plan = tier.find_subscription_by_type(yearly)
    subscription.save
    self.stripe_subscription_token = subscription.id
    user.update_attribute(:tier_id, tier.id)

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

  def create_customer_by_tier(tier, yearly)
    if tier.id == 1
      Stripe::Customer.create(description: user.email, plan: 0)
    else
      Stripe::Customer.create(description: user.email, plan: tier.find_subscription_by_type(yearly), card: stripe_card_token)
    end
  end
end