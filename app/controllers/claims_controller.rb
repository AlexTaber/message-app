class ClaimsController < ApplicationController
  before_action :claim_by_id, only: [:destroy]

  def create
    @claim = Claim.new(claim_params)

    if @claim.valid?
      @claim.save
      flash[:notice] = "Claim successfully created"
    else
      flash[:warn] = "Unable to create claim, please try again"
    end

    redirect_to :back
  end

  def destroy
    if @claim.delete
      flash[:notice] = "Claim removed"
    else
      flash[:warn] = "Unable to remove claim, please try again"
    end

    redirect_to :back
  end

  private

  def claim_params
    params.require(:claim).permit(:user_id, :task_id)
  end
end