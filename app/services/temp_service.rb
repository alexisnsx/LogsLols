require "groq"
include Groq::Helpers
require 'rest-client'

@client = Groq::Client.new(api_key: "", model_id: "mixtral-8x7b-32768")

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


##### USING THIS TO DUMP SOME CODE WHICH I MIGHT USE AGAIN. DONT ERASE!
# def convert_to_json(text)
#   require "dry-schema"
#   Dry::Schema.load_extensions(:json_schema)

#   task_schema_defn = Dry::Schema.JSON do
#     required(:title).filled(:str?)
#     required(:description).filled(:str?)
#     optional(:priority).filled(:str?, included_in?: %w[Low Medium High])
#     optional(:due_date).filled(:date?)
#   end

#   task_schema = task_schema_defn.json_schema
#   messages <<
#   response = @client.chat([S("You're excellent at extracting information for tasks", json_schema: task_schema), U(text)], json: true)
#   data = JSON.parse(response["content"])
#   debugger
#   if response.count != 0
#     Conversation.create!(chat: memory, message: response)
#   end
# end

# convert_to_json_tool = {
#   type: "function",
#   function: {
#     name: "convert_to_json",
#     description: "Convert text to json",
#     parameters: {
#       type: "object",
#       properties: {
#         text: {
#           type: "string",
#           description: "The body of text you need to convert to json"
#         }
#       },
#       required: ["text"]
#     }
#   }
# }
