module ReportHelper

  EXCEL_PARSING_RULES_FILENAME = 'excel_parsing_rules.yml'

  def self.get_excel_rules
    path = Rails.root.join('config', EXCEL_PARSING_RULES_FILENAME)
    return !File.exist?(path) ? nil : YAML.load(File.read(path)).deep_symbolize_keys()
  end

  def self.delete_upload_cache
    CarrierWave.clean_cached_files!
    Rails.logger.info("Clean cache file success! Executed at #{DataTime.now}")
    rescure StandardError => e
    Rails.logger.error("Error occured when cleaning cache file! Message: #{e.message}")
  end
end
