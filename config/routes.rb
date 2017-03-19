Rails.application.routes.draw do
  devise_for :users
  post 'auth_user' => 'authentication#authenticate_user'
  root to: 'home#index'
  post 'bot_actions/process_user_input'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
