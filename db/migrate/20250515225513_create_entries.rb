class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :entries do |t|
      t.string :name
      t.string :company_name
      t.string :property_name
      t.string :address
      t.string :email
      t.string :phone_number
     
      t.timestamps
    end
  end
end
