class HousingReportController < ApplicationController

  UPLOAD_REPORT_PARAM_KEY = 'upload'
  LIST_REPORT_SHOW_KEYS = %w(id digest original_filename parsed report created_at)

  def upload_report
    success = false
    responseJson = Hash.new

    report = HousingReport.new(report: params[UPLOAD_REPORT_PARAM_KEY], parsed: false)
    begin
      report.save!
      success = true
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
      Rails.logger.error(e.message)
      responseJson['error'] = e.message
    ensure
      responseJson['success'] = success
      render json: responseJson
    end
  end

  def delete_report
    success = false
    responseJson = Hash.new

    begin
      report = HousingReport.find_by!(id: params[:id])
      report.remove_report!
      report.destroy!
      success = true
    rescue StandardError => e
      Rails.logger.error(e.message)
      responseJson['error'] = e.message
    ensure
      responseJson['success'] = success
      render responseJson
    end

  end

  def list_report
    results =  HousingReport.select(LIST_REPORT_SHOW_KEYS).order('created_at DESC').page(params[:page]) || Array.new
    render json: { reports: results.as_json }.merge!(results.empty? ? {} : { totalPage: results.total_pages, currentPage: params[:page] })
  end
end
