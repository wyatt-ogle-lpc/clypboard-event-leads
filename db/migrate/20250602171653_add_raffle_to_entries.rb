class AddRaffleToEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :raffle_winner, :boolean
  end
end
