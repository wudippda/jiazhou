class ExcelReportController < ApplicationController

  UPLOAD_EXCEL_PARAM_KEY = 'upload'
  SHOW_KEYS = %w(id digest original_filename parsed excel created_at)

  def upload_report
    uploadSuccess = false
    responseJson = {}
    report = ExcelReport.new(excel: params[UPLOAD_EXCEL_PARAM_KEY], parsed: false)
    begin
      report.save!
      uploadSuccess = true
    rescue ActiveRecord::RecordInvalid => e
      uploadSuccess = false
      responseJson['errorMsg'] = e.message
      Rails.logger.error(e.message)
    ensure
      responseJson['uploadSuccess'] = uploadSuccess
      render json: responseJson
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
    results =  ExcelReport.select(SHOW_KEYS).page(params[:page])
    render json: {reports: results.as_json, totalPage: results.total_pages, currentPage: params[:page]}
  end
end
