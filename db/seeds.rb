# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "open-uri"

require 'date'

puts 'creating new users'

alexis = User.create!(email: 'alexis@test.com', password: '123456')

puts 'creating new taks'

new_tasks = [
  { title: 'Finish reading and replying emails',
    description: 'Double check staff overtime and expense claims',
    priority: 'High',
    due_date: Date.today,
    reminder_date_time:, DateTime.now + 30.minutes,
    user: alexis
    },

  { title: ''

  }








]
