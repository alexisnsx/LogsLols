# frozen_string_literal: true

Groq.configure do |config|
  config.api_key = ENV["GROQ_API_KEY"]
  config.model_id = "llama3-70b-8192"
end


# ID	REQUESTS   PER MINUTE	REQUESTS PER DAY	TOKENS PER MINUTE
# llama3-8b-8192	30	        14,400	       30,000
# gemma-7b-it	    30	        14,400	       15,000
# mixtral-8x7b-32768	30	    14,400	       5,000
# llama3-70b-8192	30	        14,400	       6,000
