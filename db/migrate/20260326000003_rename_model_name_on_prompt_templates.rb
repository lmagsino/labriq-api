class RenameModelNameOnPromptTemplates < ActiveRecord::Migration[7.1]
  def change
    rename_column :prompt_templates, :model_name, :ai_model_name
  end
end
