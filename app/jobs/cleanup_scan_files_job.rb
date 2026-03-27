class CleanupScanFilesJob
  include Sidekiq::Job

  def perform(scan_id)
    scan = Scan.find(scan_id)
    scan.lab_files.purge
    scan.prescription_files.purge
  rescue ActiveRecord::RecordNotFound
    # Scan was deleted, nothing to clean up
  end
end
