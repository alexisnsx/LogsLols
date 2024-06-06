# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# require "open-uri" - (Allows us to open URL)
require 'date'

puts 'Destroying database'
Task.destroy_all
User.destroy_all

puts 'creating new users'

alexis = User.create!(email: 'alexis@test.com', password: '123abc')

puts 'creating new tasks'

new_tasks = [
  { title: 'Finish reading and replying emails',
    description: 'Double check staff overtime and expense claims',
    priority: 'High',
    documents: ['/documents/joker_test.jpeg'],
    due_date: Date.today,
    reminder_datetime: DateTime.now + 30.minutes,
    user: alexis },

  { title: 'Printing documents',
    description: 'Check and print supporting documents for claims',
    priority: 'High',
    documents: ['/documents/joker_test.jpeg'],
    due_date: Date.today,
    reminder_datetime: DateTime.now + 60.minutes,
    user: alexis },

  { title: 'Signing and stamping',
    description: 'Get printed documents to head for authorisation',
    priority: 'High',
    due_date: Date.today,
    reminder_datetime: DateTime.now + 120.minutes,
    user: alexis },

  { title: 'Archiving',
    description: 'File documents and pass to archives',
    priority: 'Low',
    due_date: Date.new(2024, 05, 31),
    reminder_datetime: DateTime.new(2024, 05, 30, 18, 00, 00),
    user: alexis },

  { title: 'Prepare inter-co reconciliations',
    description: 'Identify transactions, double check for duplicates and prepare journal entries',
    priority: 'Medium',
    due_date: Date.new(2024, 05, 20),
    reminder_datetime: DateTime.new(2024, 05, 19, 15, 30, 00),
    user: alexis }
]

new_tasks.each do |attributes|
  task = Task.create!(attributes)

  puts "Created #{task.title}"
end

