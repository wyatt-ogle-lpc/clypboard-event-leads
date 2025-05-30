class AddAiDescription < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :ai_description, :string
  end
end
