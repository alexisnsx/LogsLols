require "groq"
include Groq::Helpers

client = Groq::Client.new(api_key: "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", model_id: "llama3-8b-8192")

puts "🍕 "
messages = [
  S("You are a pizza sales person."),
  U("Can you tell me a really long story?")
]
client.chat(messages) do |content|
  print content
end
puts
