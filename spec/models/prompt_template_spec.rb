require 'rails_helper'

RSpec.describe PromptTemplate, type: :model do
  describe "validations" do
    subject { build(:prompt_template) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:version) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:ai_model_name) }
  end

  describe "scopes" do
    let!(:active_template)   { create(:prompt_template, active: true) }
    let!(:inactive_template) { create(:prompt_template, version: 2, active: false) }

    it ".active returns only active templates" do
      expect(PromptTemplate.active).to include(active_template)
      expect(PromptTemplate.active).not_to include(inactive_template)
    end
  end

  describe ".current" do
    let!(:old_version) { create(:prompt_template, version: 1, active: true) }
    let!(:new_version) { create(:prompt_template, version: 2, active: true) }
    let!(:inactive)    { create(:prompt_template, version: 3, active: false) }

    it "returns the highest active version for the given name" do
      expect(PromptTemplate.current("lab_analysis")).to eq(new_version)
    end

    it "returns nil if no active template exists" do
      expect(PromptTemplate.current("nonexistent")).to be_nil
    end
  end
end
