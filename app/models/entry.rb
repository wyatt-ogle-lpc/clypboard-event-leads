class Entry < ApplicationRecord
  include HTTParty

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  
end



