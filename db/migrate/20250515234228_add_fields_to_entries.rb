class AddFieldsToEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :name, :string
    add_column :entries, :address, :string
    add_column :entries, :email, :string
    add_column :entries, :phone_number, :string
  end
end
