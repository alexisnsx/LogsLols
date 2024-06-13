require "groq"
include Groq::Helpers
require 'rest-client'

client = Groq::Client.new(api_key: "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", model_id: "llama3-8b-8192")


def tavily_search(query:)
  url = "https://api.tavily.com/search"
  response = RestClient.post(url,
    {
      api_key: "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",
      query:,
      search_depth: "basic",
      include_answer: false,
      include_images: false,
      include_raw_content: true,
      max_results: 1,
      include_domains: [],
      exclude_domains: []
    }.to_json,
    {content_type: :json, accept: :json}
  )
  JSON.parse(response)
  data
end

tavily_search(query: 'what do i want to eat today?')
