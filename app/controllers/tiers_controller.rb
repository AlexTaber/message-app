class TiersController < ApplicationController
  def index
    @pro = Tier.find_by(name: "Pro")
    @tiers = Tier.all
  end
end