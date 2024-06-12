# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'date'

puts 'Destroying database'
Conversation.destroy_all
Chat.destroy_all
Task.destroy_all
User.destroy_all

puts 'creating new users'

alexis = User.create!(email: 'alexis@test.com', password: '123abc')

puts 'creating new chat'

chat = Chat.create!(user: alexis)

puts 'creating new conversation'

Conversation.create!(user_message: "Tell me a joke", ai_message: "Knock knock! Who's there? Said the knocker.", chat: chat)

puts 'creating new tasks'

new_tasks = [
  { title: 'Finish reading and replying emails',
    description: 'Double check staff overtime and expense claims',
    priority: 'High',
    documents_path: ['documents/Expedia.pdf', 'documents/SampleMinutes.pdf', 'documents/ESGrelease.pdf'],
    due_date: Date.today,
    reminder_datetime: DateTime.now + 30.minutes,
    user: alexis },

  { title: 'Printing documents',
    description: 'Check and print supporting documents for claims',
    priority: 'High',
    documents_path: ['documents/claims-guide.pdf', 'documents/drivingassessment.pdf'],
    due_date: Date.today,
    reminder_datetime: DateTime.now + 60.minutes,
    user: alexis },

  { title: 'Signing and stamping',
    description: 'Get printed documents to finance head for authorisation',
    priority: 'High',
    documents_path: ['documents/CPF.pdf'],
    due_date: Date.today,
    reminder_datetime: DateTime.now + 120.minutes,
    user: alexis },

  { title: 'Prepare inter-co reconciliations',
    description: 'Identify transactions, double check for duplicates and prepare journal entries',
    priority: 'Medium',
    documents_path: ['documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 05, 20),
    reminder_datetime: DateTime.new(2024, 05, 12, 10, 30, 00),
    user: alexis },

  { title: 'Project Management',
    description: 'Prepare project to develop a comprehensive plan outlining timelines, milestones, and key deliverables. Stakeholders meeting with all project stakeholders to discuss project goals and expectations.',
    priority: 'Medium',
    documents_path: ['documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 05, 20),
    user: alexis },

  { title: 'Personal Development',
    description: 'Complete LeWagon Bootcamp. Finish the Web Developement course to improve/web development coding skills.',
    priority: 'High',
    documents_path: ['documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 05, 20),
    reminder_datetime: DateTime.new(2024, 05, 12, 10, 30, 00),
    user: alexis },

  { title: 'Office Administration',
    description: 'Inventory Check: Conduct a detailed inventory check of all office supplies and reorder any necessary items.
    ',
    priority: 'Medium',
    documents_path: ['documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 05, 20),
    user: alexis },

  { title: 'Marketing Campaign',
    description: 'Social Media Content Plan to develop a content calendar for social media posts for the next quarter, focusing on engagement and brand awareness. Create email newsletter draft for the monthly email newsletter, including articles, news, and updates.
    ',
    priority: 'Medium',
    documents_path: ['documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 05, 20),
    user: alexis },

  { title: 'Event Planning',
    description: 'Venue booking. Please conduct research and book a suitable venue for the annual company retreat, ensuring it meets all requirements and budget constraints. Guest List Finalization: Compile and finalize the guest list for the upcoming conference, ensuring all key stakeholders are included.',
    priority: 'Low',
    documents_path: ['documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 05, 20),
    reminder_datetime: DateTime.new(2024, 05, 12, 10, 30, 00),
    user: alexis },

  { title: 'Financial Management',
  description: 'Monthly Budget Review: Analyze and review the monthly budget, track expenses, and adjust allocations as needed to stay within financial goals.',
  priority: 'Low',
  documents_path: ['documents/pdpc-guidelines.pdf'],
  due_date: Date.new(2024, 05, 20),
  reminder_datetime: DateTime.new(2024, 07, 19, 15, 30, 00),
  user: alexis },

  { title: 'Health and Wellness',
    description: 'Weekly meal plan to prepare meals for the upcoming week, focusing on balanced nutrition and portion control to maintain a healthy diet. Exercise routine to follow a personalized exercise routine, including a mix of cardio, strength training, and flexibility exercises, to achieve fitness goals.',
    priority: 'Low',
    documents_path: ['documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 05, 20),
    reminder_datetime: DateTime.new(2024, 07, 19, 15, 30, 00),
    user: alexis },

  { title: 'Customer Support',
    description: 'Resolve Customer Tickets: Review and resolve all outstanding customer support tickets, ensuring timely and satisfactory responses to all inquiries and issues.',
    priority: 'Low',
    documents_path: ['documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 05, 20),
    reminder_datetime: DateTime.new(2024, 05, 19, 15, 30, 00),
    user: alexis }

]

new_tasks.each do |attributes|
  task = Task.new(attributes.except(:documents_path))
  attributes[:documents_path].each do |path|
    task.documents.attach(
      io: File.open(path),
      filename: "#{path}",
      content_type: 'application/pdf',
      identify: false
    )
    task.save!
    puts "Created #{task.title}"
  end
end
