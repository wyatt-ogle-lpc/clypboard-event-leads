class AddCompanyAndPropertyNameToEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :company_name, :string
    add_column :entries, :property_name, :string
  end
end
