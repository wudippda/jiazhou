class ExcelReportController < ApplicationController

  UPLOAD_EXCEL_PARAM_KEY = 'upload'
  SHOW_KEYS = %w(id digest original_filename parsed excel)

  def upload_report
    uploadSuccess = false
    report = ExcelReport.new(excel: params[UPLOAD_EXCEL_PARAM_KEY], parsed: false)
    begin
      report.save!
      uploadSuccess = true
    rescue ActiveRecord::RecordInvalid => e
      uploadSuccess = false
      Rails.logger.error(e.message)
    ensure
      render json: {uploadSuccess: uploadSuccess}
    end
  end

  def delete_report
    deleteSuccess = false
    excelReport = ExcelReport.find_by(id: params[:id])
    if excelReport
      begin
        excelReport.remove_excel!
        excelReport.destroy!
        deleteSuccess = true
      rescue StandardError => e
        Rails.logger.error(e.message)
      end
    else
      deleteSuccess = true
    end
    render json: {deleteSuccess: deleteSuccess}
  end

  def list_report
    render json: {reports: ExcelReport.select(SHOW_KEYS).page(params[:page]).as_json}
  end
end
