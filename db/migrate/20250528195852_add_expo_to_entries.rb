class AddExpoToEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :expo, :string
  end
end
