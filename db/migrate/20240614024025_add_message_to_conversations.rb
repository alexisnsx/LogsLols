class AddMessageToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :message, :jsonb
    remove_column :conversations, :user_message, :text
    remove_column :conversations, :ai_message, :text
  end
end
