class UsersController < ApplicationController
  before_action :user_by_id, only: [:home]
  def new
    @user = User.new
  end

  def create
  end

  def destroy
  end

  def home
  end

  private

  def user_by_id
    @user = User.find_by(id: params[:id])
  end

end
