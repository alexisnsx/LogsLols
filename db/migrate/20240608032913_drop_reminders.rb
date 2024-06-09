class DropReminders < ActiveRecord::Migration[7.1]
  def change
    drop_table :reminders
  end
end
