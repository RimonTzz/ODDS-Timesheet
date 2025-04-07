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
    bounding_box([ 0, cursor ], width: bounds.width) do
      bounding_box([ 0, cursor ], width: bounds.width - 160) do
        text "Monthly Time Sheet", size: 20, style: :bold
        move_down 10

        formatted_text [
          { text: "Name", styles: [:bold] },
          { text: " : #{@user_project.user.first_name} #{@user_project.user.last_name}" }
        ], size: 10

        formatted_text [
          { text: "Site", styles: [:bold] },
          { text: " : #{@user_project.project.site.site_name}" }
        ], size: 10

        formatted_text [
          { text: "Project", styles: [:bold] },
          { text: " : #{@user_project.project.project_name}" }
        ], size: 10

        formatted_text [
          { text: "Month", styles: [:bold] },
          { text: " : #{format_month(@month)}" }
        ], size: 10
      end

      logo_path = Rails.root.join("app/assets/images/icon/ODT_logo.png")
      if File.exist?(logo_path)
        bounding_box([bounds.right - 80, cursor + 85], width: 150) do
          image logo_path, width: 75
        end
      end
    end
    move_down 50
  end

  def table_content
    column_widths = [ 100, 50, 50, 80, 260 ]

    table timesheet_rows, width: bounds.width, column_widths: column_widths do
      row(0).font_style = :bold
      row(0).background_color = "999999"
      self.header = true
      cells.borders = [ :bottom, :left, :right, :top ]
      cells.size = 10
    end

    move_down 50

    signature_y = cursor

    bounding_box([ 0, signature_y ], width: bounds.width / 2 - 10, height: 110) do
      text "Initial By (Odd-e)", align: :center, valign: :top
      move_down 50
      stroke_horizontal_rule
      move_down 10
      text "(  #{@user_project.user.first_name} #{@user_project.user.last_name}  )", align: :center
      text "date: #{Date.today.strftime('%d / %m / %Y')}", align: :center    
    end

    bounding_box([ bounds.width / 2 + 10, signature_y ], width: bounds.width / 2 - 10, height: 110) do
      text "Approve By (Client)", align: :center, valign: :top
      move_down 50
      stroke_horizontal_rule
      move_down 10
      text "(                                                        )", align: :center
      text "date:       /        /        ", align: :center
    end
  end

  def timesheet_rows
    [
      [
        { content: "Date", align: :center },
        { content: "in", align: :center },
        { content: "out", align: :center },
        { content: "status", align: :center },
        { content: "Activity", align: :center }
      ]
    ] +
      generate_month_days.map do |date|
        timesheet = @timesheets.find { |t| t.date == date }
        is_weekend = date.saturday? || date.sunday?
        is_holiday = Holiday.is_holiday?(date)
        row_color = (is_weekend || is_holiday) ? "CCCCCC" : nil

        [
          { content: format_date(date), background_color: row_color, align: :center },
          { content: safe_time_format(timesheet&.check_in), background_color: row_color, align: :center },
          { content: safe_time_format(timesheet&.check_out), background_color: row_color, align: :center },
          { content: safe_text(timesheet&.work_status), background_color: row_color },
          { content: timesheet&.work_description.to_s || "", background_color: row_color }
        ]
      end
  end

  private

  def format_date(date)
    date.strftime("%d %B %Y")
  end

  def format_month(month_str)
    year, month = month_str.split("-").map(&:to_i)
    date = Date.new(year, month, 1)
    date.strftime("%B %Y")
  end

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
