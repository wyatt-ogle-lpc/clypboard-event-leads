require 'net/http'
require 'uri'
require 'json'

class EntriesController < ApplicationController


  


  def landing_page
    @expo = params[:expo] || params.dig(:entry, :expo)
    # You can pass @expo to the view, and pre-fill it or hide it in a hidden field
    @entry = Entry.new(expo: @expo)    end

    def game
      @skipped = false
  end

  def create
    Rails.logger.info "[DEBUG] EntriesController#create called with params: #{params.inspect}"

    @expo = params[:expo] || params.dig(:entry, :expo)
    @entry = Entry.new(entry_params.merge(expo: @expo))

      # Validate email with ZeroBounce before saving
      email_status = validate_email_with_zerobounce(@entry.email)
      if email_status != "valid"
        @entry.errors.add(:email, "Please enter a valid email address")
        render :landing_page, status: :unprocessable_entity
        return
      end

      # Address validation using Google Geocoding API
    geocode_result = geocode_address(@entry.address)
    @entry.city = extract_city_from_geocode_result(geocode_result)
    if geocode_result["status"] == "OK"
      location = geocode_result["results"][0]["geometry"]["location"]
      @entry.latitude = location["lat"]
      @entry.longitude = location["lng"]
    else
      @entry.errors.add(:address, "Please enter a valid address")
      render :landing_page, status: :unprocessable_entity
      return
    end

        if @entry.save
          ClypboardLeadJob.perform_later(@entry.id)
          Rails.logger.info "ENQUEUED ClypboardLeadJob for Entry ID: #{@entry.id}"

          if @expo.present?
            redirect_to expo_game_path(expo: @expo)
          else
            redirect_to game_path
          end
          
        else
          render :landing_page, status: :unprocessable_entity
        end
  end

  def game
    @expo = params[:expo]
    # Set up any game variables here, or just render the game view
  end

  
    def thanks
    end

    def geocode_address(address)
      api_key = Rails.application.credentials.dig(:google_maps, :api_key)
      url = URI("https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode_www_form_component(address)}&key=#{api_key}")
      response = Net::HTTP.get(url)
      JSON.parse(response)
    end
    
  
    private
  
    def entry_params
      params.require(:entry).permit(
        :name,
        :company_name,
        :property_name,
        :address,
        :email,
        :phone_number,
        :comments,         # add this for textarea
        :general_pest,         # add this for checkbox 1
        :termites,         # add this for checkbox 2
        :rodents,         # add this for checkbox 3
        :bedbugs,         # add this for checkbox 4
        :other,
        :expo
      )
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

    def extract_city_from_geocode_result(geocode_result)
      # Assume geocode_result is a parsed JSON Hash from Google Geocoding API
      components = geocode_result.dig("results", 0, "address_components")
      city = components.find { |comp| comp["types"].include?("locality") }
      city_name = city ? city["long_name"] : nil
      city_name
    end
    
  end
  