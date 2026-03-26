class CreateFeedbacks < ActiveRecord::Migration[7.1]
  def change
    create_table :feedbacks do |t|
      t.references :scan, null: false, foreign_key: true
      t.references :lab_result, null: true, foreign_key: true
      t.string :feedback_type
      t.text :comment

      t.timestamps
    end
  end
end
