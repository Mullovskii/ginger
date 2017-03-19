class BotActionsController < ApplicationController
  def process_user_input
    @bot_action = current_user.bot_actions.build(bot_action_params)
    if @bot_action.save
      @return_user_input = @bot_action.user_input
      computed_path = @bot_action.process_input(@return_user_input)
      @return_bot_response = @bot_action.bot_response
      #puts "\n\nCOMPUTED PATH: #{computed_path.inspect}\n\n"
      if computed_path.present?
        #redirection to computed_path
        render js: "window.location = '#{computed_path}'"
      end
    end
    respond_to do |format|
      format.js
      #format.js { render :json { :only => :name }.to_json }
      #json_response(@bot_action)
    end
  end
 
  private
 
  def bot_action_params
    params.require(:bot_action).permit(:user_input, :user_id)
  end
end