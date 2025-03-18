class TimesheetsController < ApplicationController
  before_action :authenticate_user!

  def index
    @timesheets = current_user.admin? ? Timesheet.all : current_user.timesheets
  end

  def new
    @timesheet = Timesheet.new
  end

  def create
    @timesheet = current_user.timesheets.build(timesheet_params)
    if @timesheet.save
      redirect_to timesheets_path, notice: "บันทึกข้อมูลสำเร็จ"
    else
      render :new
    end
  end

  def export_pdf
    @timesheets = current_user.admin? ? Timesheet.all : current_user.timesheets
    respond_to do |format|
      format.pdf do
        pdf = TimesheetPdf.new(@timesheets)
        send_data pdf.render, filename: "timesheet.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  private

  def timesheet_params
    params.require(:timesheet).permit(:date, :clock_in, :clock_out, :notes)
  end
end
