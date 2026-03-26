class CreatePromptTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :prompt_templates do |t|
      t.string :name, null: false
      t.integer :version, null: false
      t.text :content, null: false
      t.string :model_name, null: false
      t.boolean :active, default: false, null: false

      t.timestamps
    end

    add_index :prompt_templates, [:name, :version], unique: true
    add_index :prompt_templates, :active
  end
end
