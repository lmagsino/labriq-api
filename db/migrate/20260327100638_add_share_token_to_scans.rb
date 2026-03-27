class AddShareTokenToScans < ActiveRecord::Migration[7.1]
  def change
    add_column :scans, :share_token, :string
    add_index :scans, :share_token, unique: true
  end
end
