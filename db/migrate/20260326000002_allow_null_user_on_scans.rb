class AllowNullUserOnScans < ActiveRecord::Migration[7.1]
  def change
    change_column_null :scans, :user_id, true
  end
end
