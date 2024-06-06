class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.text :user_message
      t.text :ai_message
      t.references :chat, null: false, foreign_key: true

      t.timestamps
    end
  end
end
