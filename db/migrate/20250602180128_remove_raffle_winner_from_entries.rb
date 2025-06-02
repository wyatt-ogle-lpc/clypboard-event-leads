class RemoveRaffleWinnerFromEntries < ActiveRecord::Migration[8.0]
  def change
    remove_column :entries, :raffle_winner, :boolean
  end
end
