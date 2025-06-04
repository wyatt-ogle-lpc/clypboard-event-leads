

class RaffleController < ApplicationController

    def raffle
        @expo = params[:expo]

        time_limit = 24.hours.ago

        @entries = Entry.where("LOWER(expo) = ?", @expo.to_s.downcase)
                        .where("created_at >= ?", time_limit)

        #only wants entries from the last 24 hours to eliminate invalid entries
        
        @entries.each_with_index do |entry, i|
            Rails.logger.debug "[DEBUG] Elligible Entry ##{i + 1}: #{entry.attributes.inspect}"
        end
          
        
        @winner = @entries.order("RANDOM()").first

        if @winner
            Rails.logger.debug "[DEBUG] Winner is: #{@winner.name} email: #{@winner.email}"
          else
            Rails.logger.debug "[DEBUG] No winner was found (likely no eligible entries)"
          end
          

      end

end