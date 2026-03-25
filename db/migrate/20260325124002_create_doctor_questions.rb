class CreateDoctorQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :doctor_questions do |t|
      t.references :scan, null: false, foreign_key: true
      t.text :question
      t.integer :sort_order

      t.timestamps
    end
  end
end
