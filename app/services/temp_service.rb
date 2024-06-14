require "groq"
include Groq::Helpers
require 'rest-client'

@client = Groq::Client.new(api_key: "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", model_id: "mixtral-8x7b-32768")

# def tavily_search(query:)
#   url = "https://api.tavily.com/search"
#   response = RestClient.post(url,
#     {
#       api_key: "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",
#       query:,
#       search_depth: "basic",
#       include_answer: true,
#       include_images: false,
#       include_raw_content: false,
#       max_results: 5,
#       include_domains: [],
#       exclude_domains: []
#     }.to_json,
#     {content_type: :json, accept: :json}
#   )
#   data = JSON.parse(response)
#   results = data["results"]
#   pp results.count

#   pp '-----------------------'
#   pp 'starting map'
#   selected_results = results.first(3).map do |result|
#     result.fetch("content")
#   end.join("\n")
#   # pp selected_results
#   pp 'tavily api called'

#   pp 'starting groq client call'
#   test = @client.chat([
#     S("You are a helpful assistant who can summarise long texts into a short paragraph and replies as if we are friends. You don't know who the other party is and gives them a summary based on their query."),
#     U(selected_results)
#   ])
#   pp 'groq client call ended'
#   test

# end



# def trialResponse()
#   response = @client.chat([
#     S("You are a helpful assistant who can summarise long texts into a short paragraph and replies as if we are friends."),
#     U("With 10 days in Bali, you can visit the highlights, a few hidden gems, and have plenty of downtime in Ubud and at the beaches.\nTours of Bali\nJoining a tour takes the hassle out of arranging transportation and allows you to do something unique, such as taking a mud bath with elephants or swimming with manta rays.\n BALI: Learn more about Bali in our guide to the best things to do in Bali, how to visit the Aling-Aling Waterfalls, what it is like to visit Bali on Nyepi Day, and how to do the Mount Batur Sunrise Hike.\n Pura Lempuyang | Best Things to Do in Bali\nGate of Heaven | Best Things to Do in Bali\nThere is a large carpark at the base of the temple. Visit the rice terraces, relax on its pristine beaches, visit the ornate temples, and learn more about the Balinese culture…these all top the list of the best things to do in Bali.\n It’s a great spot to visit for budgets of all sizes and perfect for those in search of outdoor adventures, cultural experiences, and time on some of the most beautiful beaches in the world.\n"),
#   ])
#   response
# end

def tavily_search(query:)
  url = "https://api.tavily.com/search"
  response = RestClient.post(url, {
    api_key: "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",
    query:,
    search_depth: "basic",
    include_answer: false,
    include_images: false,
    include_raw_content: false,
    max_results: 3,
    include_domains: [],
    exclude_domains: []
  }.to_json, {
    content_type: :json, accept: :json
  })
  data = JSON.parse(response)
  results = data["results"]
  "First Paragraph: #{results[0]["content"]}, Second Paragraph: #{results[1]["content"]}, Third Paragraph: #{results[2]["content"]}"
end


# pp trialResponse()
pp tavily_search(query: "what can i do in bali?")
