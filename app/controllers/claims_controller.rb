class ClaimsController < ApplicationController
  before_action :claim_by_id, only: [:destroy]

  def create
    @claim = Claim.new(claim_params)

    if @claim.valid?
      @claim.save
      claim_pusher_event(@claim.task)
      flash[:notice] = "Claim successfully created"
    else
      flash[:warn] = "Unable to create claim, please try again"
    end

    if request.xhr?
      render text: "Done"
    else
      redirect_to :back
    end
  end

  def destroy
    task = @claim.task

    if @claim.delete
      flash[:notice] = "Claim removed"
      claim_pusher_event(task)
    else
      flash[:warn] = "Unable to remove claim, please try again"
    end

    if request.xhr?
      render text: "Done"
    else
      redirect_to :back
    end
  end

  private

  def claim_params
    params.require(:claim).permit(:user_id, :task_id)
  end

  def claim_by_id
    @claim = Claim.find_by(id: params[:id])
  end

  def claim_pusher_event(task)
    task.message.conversation.users.each do |user|
      Pusher.trigger("claim#{task.message.conversation.token}#{user.id}", 'new-claim', {
        task_id: task.id,
        conversation_token: task.message.conversation.token,
        task_html: (render_to_string partial: "tasks/task", locals: { task: task, message: task.message, user: user } )
      })
    end
  end
end