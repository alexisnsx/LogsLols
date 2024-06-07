class ChangeStatusInTask < ActiveRecord::Migration[7.1]
  def change
    change_column :tasks, :status, :string, default: "Incomplete"
  end
end
