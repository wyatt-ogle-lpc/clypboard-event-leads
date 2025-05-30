class AddCityToEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :city, :string
  end
end
