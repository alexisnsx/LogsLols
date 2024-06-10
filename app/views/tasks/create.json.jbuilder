# if @monument.persisted?
#   json.form render(partial: "monuments/form", formats: :html, locals: {monument: Monument.new})
#   json.inserted_item render(partial: "monuments/monument", formats: :html, locals: {monument: @monument})
# else
#   json.form render(partial: "monuments/form", formats: :html, locals: {monument: @monument})
# end

if @task.persisted?
  json.form render(partial: "tasks/form", formats: :html, locals: {task: Task.new})
  json.inserted_item render(partial: "tasks/task", formats: :html, locals: { task: @task, index: 0})
else
  json.form render(partial: "tasks/form", formats: :html, locals: {task: @task})
end
