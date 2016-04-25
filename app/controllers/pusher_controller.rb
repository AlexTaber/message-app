class PusherController < ApplicationController

  def auth
    if current_user
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
        :user_id => current_user.id,
        :user_info => {
          :name => current_user.name,
          :email => current_user.email
        }
      })
      render :json => response
    else
      render :text => "Forbidden", :status => '403'
    end
  end

  def webhook
    webhook = Pusher::WebHook.new(request)
    if webhook.valid?
      Array(params[:events]).each do |e|
        next unless e[:name] == 'member_added' || e[:name] == 'member_removed'
        Redis.current.send(e[:name] == 'member_added' ? :sadd : :srem, "active_users", e[:user_id])
      end
      render text: 'ok'
    else
      render text: 'invalid', status: 401
    end
  end

end