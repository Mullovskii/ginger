class CreateBotActions < ActiveRecord::Migration[5.0]
  def change
    create_table :bot_actions do |t|
      t.string :user_input
      t.string :bot_response
      t.references :user, foreign_key: true
      t.string :context

      t.timestamps
    end
  end
end
