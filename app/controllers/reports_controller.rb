# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[edit update destroy]

  SCAN_URL = %r{https?://\S+/reports/(\d+)$}

  def index
    @reports = Report.includes(:user).order(id: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
    @mentioning_reports = @report.mentioning_reports.order(:id).page(params[:page])
  end

  # GET /reports/new
  def new
    @report = current_user.reports.new
  end

  def edit; end

  def create
    @report = current_user.reports.new(report_params)
    urls = params[:report][:content].scan(SCAN_URL)
    ActiveRecord::Base.transaction do
      unless @report.save && @report.create_mentions(@report.id, urls)
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
    end
  end

  def update
    urls = params[:report][:content].scan(SCAN_URL)
    ActiveRecord::Base.transaction do
      unless @report.delete_all_mention && @report.update(report_params) && @report.create_mentions(@report.id, urls)
        render :edit, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
    end
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
end
