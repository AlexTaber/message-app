class TiersController < ApplicationController
  def upgrade
    redirect_to pricing_path unless current_user
  end

  def pricing
  end
end