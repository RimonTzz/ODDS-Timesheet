require "prawn"

class TimesheetPdf < Prawn::Document
  def initialize(timesheets, user_project, month)
    super()
    @timesheets = timesheets
    @user_project = user_project
    @month = month
    setup_fonts
    header
    table_content
  end

  def setup_fonts
    font_families.update(
      "Sarabun" => {
        normal: Rails.root.join("app/assets/fonts/Sarabun-Regular.ttf"),
        bold: Rails.root.join("app/assets/fonts/Sarabun-Bold.ttf")
      }
    )
    font "Sarabun"
  end

  def header
    text "รายงานการทำงาน", size: 20, style: :bold
    move_down 10
    text "โปรเจ็ค: #{@user_project.project.project_name}", size: 14
    text "เดือน: #{@month}", size: 14
    move_down 20
  end

  def table_content
    table timesheet_rows, width: bounds.width do
      row(0).font_style = :bold
      row(0).background_color = "CCCCCC"
      self.header = true
      cells.padding = 8
      cells.borders = [:bottom, :left, :right, :top]
    end
  end

  def timesheet_rows
    [["วันที่", "เวลาเข้างาน", "เวลาออกงาน", "สถานะ", "รายละเอียด"]] +
      generate_month_days.map do |date|
        timesheet = @timesheets.find { |t| t.date == date }
        is_weekend = date.saturday? || date.sunday?
        is_holiday = Holiday.is_holiday?(date)
        row_color = (is_weekend || is_holiday) ? "EEEEEE" : nil

        [
          { content: date.strftime("%d/%m/%Y"), background_color: row_color },
          { content: safe_time_format(timesheet&.check_in), background_color: row_color },
          { content: safe_time_format(timesheet&.check_out), background_color: row_color },
          { content: safe_text(timesheet&.work_status), background_color: row_color },
          { content: timesheet&.work_description.to_s || "", background_color: row_color }
        ]
      end
  end

  private

  def generate_month_days
    year, month = @month.split("-").map(&:to_i)
    (Date.new(year, month, 1)..Date.new(year, month, -1)).to_a
  end

  def safe_time_format(time)
    return "" if time.nil?
    time.strftime("%H:%M")
  rescue
    ""
  end

  def safe_text(text)
    return "" if text.nil?
    text.to_s
  end
end
