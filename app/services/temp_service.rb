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
#       include_raw_content: true,
#       max_results: 1,
#       include_domains: [],
#       exclude_domains: []
#     }.to_json,
#     {content_type: :json, accept: :json}
#   )
#   data = JSON.parse(response)

#   test = @client.chat([
#     S("I can summarise large chunks of words into a paragraph"),
#     U(data["results"][0]["raw_content"])
#   ])

#   pp test
# end



def trialResponse()
  response = @client.chat([
    S("I can summarise large chunks of words into paragraphs without saying it's from the web"),
    U("Based on the data provided, you can use a \"What Should I Eat Today Quiz\" to uncover your hidden food preferences and guide you towards the perfect dish based on your taste buds and dietary restrictions. Another option is a recipe for chicken breasts with spinach, sun-dried tomatoes, and basil in a creamy sauce for dinner tonight."),
  ])
  response
end

pp trialResponse()
# pp tavily_search(query: "what is fun in bali?")
