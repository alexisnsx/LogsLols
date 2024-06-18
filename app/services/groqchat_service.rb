class GroqchatService
  # Uses Groq ruby gem https://github.com/drnic/groq-ruby
  include ActionController::Live # allows us to stream response based on server-sent events
  include Groq::Helpers

  attr_reader :message

  def initialize(prompt: "", response:, user:, chat_number:)
    @prompt = prompt
    @response = response
    @user = user
    @chat_number = chat_number
  end

  class CompletionStream < GroqchatService
    def call
      sse = SSE.new(@response.stream, event: "message")
      messages = [
        S("You are a fabulous administrative assistant who helps the user organise their tasks easily and helps think of ideas and solutions."),
        U(@prompt)
      ]
      metadata = ""
      begin
      mixtral7b_client.chat(messages, stream: ->(chunk, response) {
        unless chunk == nil
          sse.write({ message: chunk })
        else
          metadata = response
        end
      })
      ensure
        sse.close
      end
      pp "-----------------------The metadata related to the last chat:-------------------------"
      pp metadata
    end
  end

  class ToolUseStream < GroqchatService
    def call
      # System instructions
      instructions = S(%q(You are a friendly assistant who is provided with tools to find answers for the user. If a tool is relevant, you should include the tool's response in your answer to the user. For example, based on a function call to 'get_weather_report', you receive the information of "35 degrees celsius. So hot". You should then include the specific mention of '35 degrees celsius' in your response to the user, and never mention it is from a tool. But if there are no relevant tools, answer as yourself. If url sources are provided, cite them with the anchor tag intact.))

      # User prompt
      prompt_msg = U(@prompt)

      # Call memory service to store current conversation
      Conversation.create!(chat: memory, message: prompt_msg)
      stored_messages = memory.conversations.pluck(:message)

      # Make first request to LLM
      messages = stored_messages.unshift(instructions)
      first_reply = llama70b_client.chat(messages, tools: tools)

      # Catch malformed first_reply i.e. no content and no tool calls
      if (first_reply.nil? || !first_reply.include?("content") || first_reply["content"].include?("tool-use")) && !first_reply.include?("tool_calls")
        raise StandardError # triggers RescueStream
      end

      # Format first_reply as hash
      first_reply = first_reply.symbolize_keys
      pp "-----------------------------This is the first reply:---------------------------------"
      pp first_reply

      # Return first_reply immediately (and store it) if it has no tool_calls
      return stream_direct(@response, first_reply) if !first_reply.include?(:tool_calls)

      # Else, extract information for tool call
      first_reply[:tool_calls].each do |tool_call|
        tool_call_id = tool_call["id"]
        func = tool_call["function"]["name"]
        args = tool_call["function"]["arguments"]
        args = JSON.parse(args).symbolize_keys

        # If the tool identified doesn't exist, send new system msg to correct LLM and try again
        if !tools.any? { |tool| tool[:function][:name] == func }
          messages << S("There was no relevant tool. Answer as yourself.")
          return get_final_response(@response, messages)
        else
          # If tool exists, call it and pass tool response to 2nd llm to craft final response
          messages << first_reply
          case func
          when "get_weather_report"
            call_tool(get_weather_report(**args), tool_call_id, func, messages)
          when "tavily_search"
            call_tool(tavily_search(**args), tool_call_id, func, messages)
          when "get_current_task"
            get_current_task(**args)
          when "update_current_task"
            update_current_task(**args)
          # when "create_task"
          #   call_tool(create_task(**args), tool_call_id, func, messages)
          end
        end
      end
      # pp "------------------------------------Messages:-------------------------------------"
      # pp messages
    end
  end


  class RescueStream < GroqchatService
    def call
      rescue_msg = A("Erm...😬 as I am still a young 👼 LLM, I may not be able to answer your question or I sometimes get stuck. I'm so sorry 🙇🏻‍♂️ Could you try rephrasing or ask another question instead? You can also try resetting the chat. Also, I wish to highlight that my makers are 🤡💩🤡")
      stream_direct(@response, rescue_msg)
    end
  end


  private
  # ----------------------------- STREAMING ------------------------------------

  # Use this method to fake stream a response already received
  def stream_direct(response, reply)
    sse = SSE.new(response.stream, event: "message")
    bits = reply[:content].scan(/.{1,2}/)
    joined_bits = bits.join
    sse.write({ message: joined_bits})
    Conversation.create!(chat: memory, message: reply)
    rescue ActionController::Live::ClientDisconnected
      sse.close
    ensure
      sse.close
  end

  # Use this method to stream an incoming llm response
  def get_final_response(response, messages)
    sse = SSE.new(response.stream, event: "message")
    metadata = ""
    full_reply = []
    begin
      mixtral7b_client.chat(messages, stream: ->(chunk, response) {
      unless chunk == nil
        full_reply << chunk
      else
        metadata = response
      end
    })
    ensure
      sse.write({ message: full_reply.join })
      sse.close
    end
    if full_reply.count != 0
      to_store = { role: "assistant", content: full_reply.join }
      Conversation.create!(chat: memory, message: to_store)
    end
      # pp "--------------------------The metadata related to the last chat:--------------------------"
      # pp metadata
  end

  # ----------------------------- TOOLS ------------------------------------

  # Use this to call external tools
  def call_tool(function, tool_call_id, func_name, messages)
    begin
      tool_response = function
      pp "------------------------Tool response:---------------------------"
      pp tool_response if tool_response
      messages << T(tool_response, tool_call_id: tool_call_id, name: func_name)
      get_final_response(@response, messages)
    rescue => e
      puts "An error occurred: #{e.message}"
      raise StandardError
    end
  end

  # Various tools
  def get_weather_report(city:)
    url = "https://api.openweathermap.org/data/2.5/weather?units=metric&q=#{city}&appid=#{ENV['OPENWEATHER_API_KEY']}"
    response = RestClient.get(url)
    data = JSON.parse(response)
    "Description: #{data["weather"][0]["description"]}, Temperature: #{data["main"]["temp"]}, Feels like: #{data["main"]["feels_like"]}"
  end

  def tavily_search(query:)
    url = "https://api.tavily.com/search"
    response = RestClient.post(url, {
      api_key: ENV['TAVILY_API_KEY'],
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
    "First Paragraph: #{results[0]["content"]} from source: <a href=#{results[0]["url"]}></a>, Second Paragraph: #{results[1]["content"]} from source: <a href=#{results[1]["url"]}></a>, Third Paragraph: #{results[2]["content"]} from source: <a href=#{results[2]["url"]}></a>"
  end

  def get_current_task(id:)
    task = Task.find(id)
    reply = A("Ok I've got your task: *** Task id: #{task.id}, Task: #{task.title}, Content: #{task.content} *** How may I help you with it?")
    stream_direct(@response, reply)
  end

  def update_current_task(id:, content:)
    task = Task.find(id)
    if task.update(content: content)
      reply = A("Ok I've updated the description for your task '#{task.title}' as Content: #{task.content}! Is there anything else you need help with?")
    else
      reply = A("It seems that I either can't find your task or I've forgotten the description. Can we start again (please)?")
    end
    stream_direct(@response, reply)
  end

  def create_task(title:, description:, due_date:, priority:)
    task = Task.new(
      title:,
      description:,
      due_date:,
      priority:,
      status: "Incomplete",
      user: @user
      )
    if task.save
      "Task created successfully"
    else
      "Failed to create task"
    end
  end

  # Tools list which is passed to the llm
  def tools
    get_weather_report_tool = {
      type: "function",
      function: {
        name: "get_weather_report",
        description: "Get the weather report for a city",
        parameters: {
        type: "object",
        properties: {
          city: {
            type: "string",
            description: "The city or region to get the weather report for"
          }
        },
        required: ["city"]
      }
    }
  }
    web_search_tool = {
      type: "function",
      function: {
        name: "tavily_search",
        description: "Get current news and information about places, events, personalities from the internet",
        parameters: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "The query you need to search the web for"
            }
          },
          required: ["query"]
        }
      }
    }
    get_current_task_tool = {
      type: "function",
      function: {
        name: "get_current_task",
        description: "Get the user's current task. Must be used when user says 'find my current task'.",
        parameters: {
          type: "object",
          properties: {
            id: {
              type: "integer",
              description: "The id of the task you need to search the Task database for"
            }
          },
          required: ["id"]
        }
      }
    }
    update_current_task_tool = {
      type: "function",
      function: {
        name: "update_current_task",
        description: "Updates the user's task content. Only use this tool when the user specifically says 'update my task'.",
        parameters: {
          type: "object",
          properties: {
            id: {
              type: "integer",
              description: "The id of the task you need to search the Task database for"
            },
            content: {
              type: "string",
              description: "The description to update the task with"
            }
          },
          required: ["id", "content"]
        }
      }
    }
    create_task_tool = {
      type: "function",
      function: {
        name: "create_task",
        description: "Create a new task based on the user's request",
        parameters: {
          type: "object",
          properties: {
            title: {
              type: "string",
              description: "The header of the task"
            },
            description: {
              type: "string",
              description: "The description of the task"
            },
            due_date: {
              type: "date",
              description: "The due date of the task"
            },
            priority: {
              type: "string",
              description: "The priority of the task"
            }
          },
          required: ["query"]
        }
      }
    }
    [ get_weather_report_tool, web_search_tool ]
  end

  # ----------------------------- MODELS ------------------------------------

  def models
    @_models = Groq::Model.model_ids
    # => ["llama3-8b-8192", "llama3-70b-8192", "llama2-70b-4096", "mixtral-8x7b-32768", "gemma-7b-it"]
  end

  def client
    @_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"]) do |faraday|
      # Log request and response bodies
      faraday.response :logger, logger, bodies: true
    end
  end

  def mixtral7b_client  # 32K tokens context window
    @_mixtral7b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "mixtral-8x7b-32768")
  end

  def llama8b_client
    @_llama8b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "llama3-8b-8192")
  end

  def llama70b_client  # 8K tokens context window
    @_llama70b_client ||= Groq::Client.new(api_key: ENV["GROQ_API_KEY"], model_id: "llama3-70b-8192")
  end

  # ----------------------------- MEMORY MANAGEMENT ----------------------------------

  def memory
    @_memory ||= Chat.find(@chat_number)
  end

end
