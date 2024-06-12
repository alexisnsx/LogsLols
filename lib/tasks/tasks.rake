namespace :tasks do
  desc "Update the notification dates of some Tasks"
  task renotify: :environment do
    task_titles = ["Event Planning", "Financial Management", "Health and Wellness"]
    tasks = task_titles.map { |title| Task.find_by(title:) }

    tasks.each do |task|
      task.reminder_datetime = DateTime.new(2024, 05, 19, 15, 30, 00)
      task.save!
    end

    puts "tasks renotified"
  end
end
