if @task.persisted?
  json.form render(partial: "tasks/form", formats: :html, locals: {task: Task.new})
  json.inserted_item render(partial: "tasks/newtask", formats: :html, locals: { task: @task, index: 0})
else
  json.form render(partial: "tasks/form", formats: :html, locals: {task: @task})
end
