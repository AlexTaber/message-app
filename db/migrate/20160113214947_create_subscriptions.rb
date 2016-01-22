class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id, null: false
      t.string  :stripe_customer_token
      t.string  :stripe_subscription_token

      t.timestamps null: false
    end
  end
end
