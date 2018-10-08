module ReportHelper

  def self.delete_upload_cache
    CarrierWave.clean_cached_files!
    Rails.logger.info("Clean cache file success! Executed at #{DataTime.now}")
    rescure StandardError => e
    Rails.logger.error("Error occured when cleaning cache file! Message: #{e.message}")
  end

end
