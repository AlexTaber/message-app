class Subscription < ActiveRecord::Base
  belongs_to :user

  attr_accessor :stripe_card_token

  def save_with_payment(tier_id)
    if valid?
      customer = Stripe::Customer.create(description: user.email, plan: tier_id - 1, card: stripe_card_token)
      self.stripe_customer_token = customer.id
      save!
      user.update_attribute(:tier_id, tier_id)
    end
  rescue Stripe::InvalidRequestError => e
    user.update_attribute(:tier_id, 1)
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end
end