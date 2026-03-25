class CreateLabResults < ActiveRecord::Migration[7.1]
  def change
    create_table :lab_results do |t|
      t.references :scan, null: false, foreign_key: true
      t.string :name
      t.string :value
      t.string :unit
      t.string :status
      t.string :reference_range
      t.text :explanation
      t.integer :sort_order

      t.timestamps
    end
  end
end
