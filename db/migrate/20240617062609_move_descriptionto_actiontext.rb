class MoveDescriptiontoActiontext < ActiveRecord::Migration[7.1]
  def change
    Task.all.find_each do |task|
      task.update(content: task.description)
    end

    remove_column :tasks, :description
  end
end
