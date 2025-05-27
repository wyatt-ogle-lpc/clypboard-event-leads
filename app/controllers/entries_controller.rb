require 'net/http'
require 'uri'
require 'json'

def submit_lead_to_clypboard(entry)

end


class EntriesController < ApplicationController
    def landing_page
      @entry = Entry.new
    end
  
    def create
      @entry = Entry.new(entry_params)

    # Validate email with ZeroBounce before saving
    email_status = validate_email_with_zerobounce(@entry.email)
    if email_status != "valid"
      @entry.errors.add(:email, "Please enter a valid email address")
      render :landing_page, status: :unprocessable_entity
      return
    end

      if @entry.save
        submit_lead_to_clypboard(@entry)
        redirect_to thanks_path
      else
        render :landing_page, status: :unprocessable_entity
      end
    end

    def submit_lead_to_clypboard(entry)
      ClypboardLeadPoster.create_lead(entry)
    end
  
    def thanks
    end
  
    private
  
    def entry_params
      params.require(:entry).permit(:name, :company_name, :property_name, :address, :email, :phone_number)
    end

    def validate_email_with_zerobounce(email)
      api_key = Rails.application.credentials.dig(:zerobounce, :api_key)
      uri = URI("https://api.zerobounce.net/v2/validate?api_key=#{api_key}&email=#{URI.encode_www_form_component(email)}")
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)
      result["status"] # Returns "valid", "invalid", "catch-all", "unknown", etc.
    rescue => e
      Rails.logger.error "ZeroBounce error: #{e.message}"
      "unknown"
    end
    
  end
  