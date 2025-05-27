# app/services/clypboard_lead_poster.rb
require 'httparty'

class ClypboardLeadPoster
  include HTTParty
  base_uri 'https://clypboard.lloydpest.com'

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

  def self.entry_description(entry)
    <<~DESC
      Name: #{entry.name}
      Company: #{entry.company_name}
      Property: #{entry.property_name}
      Address: #{entry.address}
      Email: #{entry.email}
      Phone: #{entry.phone_number}
    DESC
  end
end
