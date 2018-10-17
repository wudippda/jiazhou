class HousingReportController < ApplicationController

  UPLOAD_REPORT_PARAM_KEY = 'upload'
  LIST_REPORT_SHOW_KEYS = %w(id digest original_filename parsed report created_at)

  def upload_report
    uploadSuccess = false
    responseJson = {}
    report = HousingReport.new(report: params[UPLOAD_REPORT_PARAM_KEY], parsed: false)
    begin
      report.save!
      uploadSuccess = true
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
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
    report = HousingReport.find_by(id: params[:id])
    if report
      begin
        report.remove_report!
        report.destroy!
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
    results =  HousingReport.select(LIST_REPORT_SHOW_KEYS).order('created_at DESC').page(params[:page])
    render json: {reports: results.as_json, totalPage: results.total_pages, currentPage: params[:page]}
  end
end
