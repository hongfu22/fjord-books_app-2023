# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[edit update destroy]

  SCAN_URL = %r{https?://\S+/reports/(\d+)$}

  def index
    @reports = Report.includes(:user).order(id: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
    @mentions = @report.mentions.order(:id).page(params[:page])
    @mentioning = @report.mentioning
  end

  # GET /reports/new
  def new
    @report = current_user.reports.new
  end

  def edit; end

  def create
    @report = current_user.reports.new(report_params)
    reports = exploit_id(@report.content)

    Report.transaction do
      raise ActiveRecord::Rollback unless @report.save

      reports.each do |report|
        @report.mention(report)
      end
      redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to @report, notice: t('controllers.common.notice_error', name: Report.model_name.human)
  rescue ActiveRecord::RecordNotUnique
    redirect_to @report, notice: t('controllers.common.notice_error', name: Report.model_name.human)
  end

  def update
    Report.transaction do
      raise ActiveRecord::Rollback unless @report.update(report_params)

      @report.delete_all_mention(@report.id)
      reports = exploit_id(@report.content)
      reports.each do |report|
        @report.mention(report)
      end
      redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to @report, notice: t('controllers.common.notice_error', name: Report.model_name.human)
  rescue ActiveRecord::RecordNotUnique
    redirect_to @report, notice: t('controllers.common.notice_error', name: Report.model_name.human)
  end

  def destroy
    @report.destroy

    redirect_to reports_url, notice: t('controllers.common.notice_destroy', name: Report.model_name.human)
  end

  private

  def set_report
    @report = current_user.reports.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:title, :content)
  end

  def exploit_id(content)
    urls = content.scan(SCAN_URL)
    reports =
      urls.flatten.map do |url|
        Report.find_by(id: url.to_i)
      end
    reports.compact
  end
end
