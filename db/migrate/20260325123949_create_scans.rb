class CreateScans < ActiveRecord::Migration[7.1]
  def change
    create_table :scans do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.integer :file_count
      t.string :urgency
      t.text :summary
      t.text :prescription_context
      t.jsonb :raw_ai_response
      t.datetime :analyzed_at

      t.timestamps
    end
  end
end
