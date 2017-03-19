class ApplicationController < ActionController::Base
  attr_reader :current_user
  #protect_from_forgery with: :exception
  before_action :new_bot_action

  protected

 def new_bot_action
    if current_user.present?
      @bot_action = BotAction.new
      @bot_chat = current_user.bot_actions.last(2)
      	if @bot_chat.length < 1
			@bot_chat << BotAction.greeting(current_user.id)
			#current_user.bot_actions.create(bot_response: "Привет! Меня зовут Хлои. Показать тебе интересные события рядом?", created_at: Time.now)
		end
    end
end


  def authenticate_request!
    unless user_id_in_token?
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
      return
    end
    @current_user = User.find(auth_token[:user_id])
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  private
  def http_token
      @http_token ||= if request.headers['Authorization'].present?
        request.headers['Authorization'].split(' ').last
      end
  end

  def auth_token
    @auth_token ||= JsonWebToken.decode(http_token)
  end

  def user_id_in_token?
    http_token && auth_token && auth_token[:user_id].to_i
  end
end