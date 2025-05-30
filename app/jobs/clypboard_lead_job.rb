class ClypboardLeadJob < ApplicationJob
  queue_as :default

  def perform(entry_id)
    entry = Entry.find(entry_id)
    ClypboardLeadPoster.create_lead(entry)
  end
end
