class AddAlreadyRaffledVariable < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :raffled, :boolean
  end
end
