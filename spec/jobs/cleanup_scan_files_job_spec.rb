require 'rails_helper'

RSpec.describe CleanupScanFilesJob do
  describe "#perform" do
    it "purges lab_files and prescription_files from the scan" do
      scan = create(:scan)

      lab_files = double("lab_files")
      prescription_files = double("prescription_files")
      allow(scan).to receive(:lab_files).and_return(lab_files)
      allow(scan).to receive(:prescription_files).and_return(prescription_files)
      allow(lab_files).to receive(:purge)
      allow(prescription_files).to receive(:purge)
      allow(Scan).to receive(:find).with(scan.id).and_return(scan)

      described_class.new.perform(scan.id)

      expect(lab_files).to have_received(:purge)
      expect(prescription_files).to have_received(:purge)
    end

    it "does nothing when the scan does not exist" do
      expect { described_class.new.perform(99999) }.not_to raise_error
    end
  end
end
