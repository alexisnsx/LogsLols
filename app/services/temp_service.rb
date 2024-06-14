require "groq"
include Groq::Helpers
require 'rest-client'

@client = Groq::Client.new(api_key: "__fill in again__", model_id: "mixtral-8x7b-32768")

def tavily_search(query:)
  url = "https://api.tavily.com/search"
  response = RestClient.post(url, {
    api_key: "__fill in again__",
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
