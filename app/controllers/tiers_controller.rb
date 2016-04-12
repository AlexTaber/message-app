class TiersController < ApplicationController
  def pricing
    @pro = Tier.find_by(name: "Pro")
    @tiers = Tier.all
  end
end