class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.string :priority
      t.string :status, default: "incomplete"
      t.date :due_date
      t.datetime :reminder_datetime
      t.references :user, null: false, foreign_key: true
      t.string :documents, array: true

      t.timestamps
    end
  end
end
