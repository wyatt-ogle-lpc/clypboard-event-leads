# app/services/clypboard_lead_poster.rb
require 'httparty'


class ClypboardLeadPoster
  include HTTParty
  base_uri 'https://clypboard.lloydpest.com'
  GPT_MODEL = 'gpt-4o-mini'  # Can be changed to other models if needed
  MAX_RETRIES = 3

  def self.create_lead(entry)
    api_key = Rails.application.credentials.clypboard_api_key

    body = {
        lead: {
            ticket_type_name: "Event Lead",
            body_raw: entry_description(entry) # Or just a string
        },  
    }

    Rails.logger.info "Posting to Clypboard with body: #{body.inspect} and api_key: #{api_key.present? ? '[PRESENT]' : '[MISSING]'}"
    puts "Sending X-Api-Key: #{api_key.inspect}"

    response = post(
  "/api/leads?api_key=#{api_key}",
  headers: {
    "Content-Type" => "application/json"
    # Do NOT send X-Api-Key unless Clypboard says you need BOTH
  },
  body: body.to_json
)

    Rails.logger.info "Clypboard response code: #{response.code}, body: #{response.body}"

    if response.code != 200
        # Try to parse JSON error details, or just log the raw body if it's not JSON
        begin
          error_details = JSON.parse(response.body)
          Rails.logger.error "Clypboard API error details: #{error_details.inspect}"
        rescue JSON::ParserError
          Rails.logger.error "Clypboard API error (non-JSON): #{response.body}"
        end
    end
  end

  def self.serpapi_search(entry)
    Rails.logger.info("Calling SerpAPI with: #{entry.company_name}, #{entry.address}, #{entry.city}")

    api_key = Rails.application.credentials.dig(:serpapi, :api_key)
    url = "https://serpapi.com/search.json"
  
    extract_info = ->(body) {
    results = JSON.parse(body)
    # --- Extract website if present ---
    website = results.dig("organic_results", 0, "link") || results.dig("knowledge_graph", "website")

    #makes it so if the address returns nil, it doesn't apply .compact on a nil
    snippets = (results["organic_results"] || []).first(2).map { |r| r["snippet"] }.compact

     # --- Build info string ---
     info = ""
        info += "Official Website: #{website}\n" if website.present?
        info += snippets.join("\n")
        info.strip
      }
  
    # 1. Try full address
    params_address = {
      q: entry.company_name,
      location: entry.address,
      api_key: api_key
    }
    response = HTTParty.get(url, query: params_address)
    info = extract_info.call(response.body)
    return info unless info.empty?
    
  
    # 2. Fallback: try city
    params_city = {
      q: entry.company_name,
      location: entry.city,
      api_key: api_key
    }
    response = HTTParty.get(url, query: params_city)
    info = extract_info.call(response.body)
    return info unless info.empty?

  
    # 3. Nothing found
    Rails.logger.info("SerpAPI: No relevant results for #{entry.company_name} at address or city. Response: #{response.body}")
    "(No relevant web results found.)"
  end
  


  def self.askChat(entry)
    api_key = Rails.application.credentials.dig(:openai, :api_key)
    uri = URI("https://api.openai.com/v1/chat/completions")

    #chatGPT generated prompt w/ tweaks from user
    prompt = <<~PROMPT
      Using only the following web search results, provide a summary of the company "#{entry.company_name}" at "#{entry.address}" for a salesperson preparing to make an introductory call.

      - First, print the company name on its own line.
      - Then, list 5-8 bullet points, each starting with a **bolded header** (e.g., "**Main Business Focus:**", etc.) followed by the most relevant facts from the web results.
      - Bullets must appear on separate lines and not be full sentences unless the information requires it.
      - If a bullet point cannot be found in the web results, omit it (do not speculate or include "not found").
      - Always end with a "**Website:**" bullet. If the website is not present in the results, state: "No specific website found in the search results."
      - Do NOT invent facts.

      Example format:

      Example Company Name
      - **Main Business Focus:** Specializes in commercial landscaping
      - **Reputation:** Known for customer service and innovation
      - **Special Qualities:** Winner of 2023 Local Business Award
      - **Other bullet points as you see fit:** etc.
      - **Website:** www.example.com

      Web search results:
      #{self.serpapi_search(entry)}
    PROMPT




    headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer #{api_key}"
    }

    body = {
      model: GPT_MODEL,  #your constant above, e.g., 'gpt-4o-mini'
      messages: [
        { role: "user", content: prompt }
      ],
      max_tokens: 150
    }.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = body

    response = http.request(request)
    json = JSON.parse(response.body)

    chat_response = json.dig("choices", 0, "message", "content")
    return chat_response
  rescue => e
    Rails.logger.error("OpenAI API error: #{e.message}")
    nil
  end

  def self.entry_description(entry)
    ai_desc = if entry.company_name.present?
      self.askChat(entry)
    else
      "This entry is for an individual, not a company. No company research was performed."
    end

    <<~DESC
      <strong>Created at:</strong> #{Time.now.strftime("%B %d, %Y at %I:%M %p %Z")}<br>

      <strong>Name:</strong> #{entry.name}<br>
      <strong>Company:</strong> #{entry.company_name}<br>
      <strong>Property:</strong> #{entry.property_name}<br>
      <strong>Address:</strong> #{entry.address}<br>
      <strong>Email:</strong> #{entry.email}<br>
      <strong>Phone:</strong> #{entry.phone_number}<br>
      <strong>Comments:</strong> #{entry.comments}<br>

      <strong>General Pest:</strong> #{entry.general_pest ? 'Yes' : 'No'}<br>
      <strong>Termites:</strong> #{entry.termites ? 'Yes' : 'No'}<br>
      <strong>Rodents:</strong> #{entry.rodents ? 'Yes' : 'No'}<br>
      <strong>Bedbugs:</strong> #{entry.bedbugs ? 'Yes' : 'No'}<br>
      <strong>Other:</strong> #{entry.other ? 'Yes' : 'No'}<br>

      <strong>Expo:</strong> #{entry.expo}<br>

      <strong>AI Desc:</strong><br>
      #{ai_desc}<br>

      <strong>Long:</strong> #{entry.longitude}, <strong>Lat:</strong> #{entry.latitude}
    DESC

  end
end
