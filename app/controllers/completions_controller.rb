class CompletionsController < ApplicationController
  def create
    @completion = Completion.new(completion_params)

    if @completion.valid?

    else


  end

  def destroy

  end

  private

  def completion_params
    params.require(:completion).permit(:user_id, :task_id)
  end
end