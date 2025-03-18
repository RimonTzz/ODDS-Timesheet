require "prawn"

class TimesheetPdf < Prawn::Document
  def initialize(timesheets)
    super()
    @timesheets = timesheets
    header
    table_content
  end

  def header
    text "รายงานการทำงาน", size: 20, style: :bold
  end

  def table_content
    table timesheet_rows do
      row(0).font_style = :bold
      self.header = true
    end
  end

  def timesheet_rows
    [["วันที่", "เวลาเข้างาน", "เวลาออกงาน", "หมายเหตุ"]] + # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets
      @timesheets.map do |t|
        [t.date, t.clock_in.strftime("%H:%M"), t.clock_out.strftime("%H:%M"), t.notes] # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets
      end
  end
end
