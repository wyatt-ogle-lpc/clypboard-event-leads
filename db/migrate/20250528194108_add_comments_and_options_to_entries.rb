class AddCommentsAndOptionsToEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :comments, :text
    add_column :entries, :general_pest, :boolean
    add_column :entries, :termites, :boolean
    add_column :entries, :rodents, :boolean
    add_column :entries, :bedbugs, :boolean
    add_column :entries, :other, :boolean
  end
end
