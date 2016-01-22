if Rails.env.development?
  Stripe.api_key = ENV['TEST_STRIPE_SECRET_KEY']
  STRIPE_PUBLISHABLE_KEY = ENV['TEST_STRIPE_PUBLISHABLE_KEY']
end

if Rails.env.production?
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  STRIPE_PUBLISHABLE_KEY = ENV['STRIPE_PUBLISHABLE_KEY']
end
