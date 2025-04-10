require "prawn"

class TimesheetPdf < Prawn::Document
  def initialize(timesheets, user_project, month)
    super(page_size: 'A4')
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
        move_down 5

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
        bounding_box([bounds.right - 80, cursor + 75], width: 150) do
          image logo_path, width: 75
        end
      end
    end
    move_down 40
  end

  def table_content
    column_widths = [90, 80, 213.28, 70, 70]  # รวมแล้ว ~540 pt พอดีกับ A4 แนวตั้ง
  
    table timesheet_rows, width: bounds.width, column_widths: column_widths do
      row(0).font_style = :bold
      row(0).background_color = "999999"
      self.header = true
      cells.borders = [:bottom, :left, :right, :top]
      cells.size = 9
      cells.inline_format = true
      cells.overflow = :shrink_to_fit
    end
  
    move_down 50
  
    signature_y = cursor
  
    bounding_box([0, signature_y], width: bounds.width / 2 - 10, height: 110) do
      text "Initial By (Odd-e)", align: :center, valign: :top
      move_down 50
      stroke_horizontal_rule
      move_down 10
      text "(  #{@user_project.user.first_name} #{@user_project.user.last_name}  )", align: :center
      text "date: #{Date.today.strftime('%d / %m / %Y')}", align: :center
    end
  
    bounding_box([bounds.width / 2 + 10, signature_y], width: bounds.width / 2 - 10, height: 110) do
      text "Approve By (Client)", align: :center, valign: :top
      move_down 50
      stroke_horizontal_rule
      move_down 10
      text "(                                                        )", align: :center
      text "date:       /        /        ", align: :center
    end
  end
  

  def timesheet_rows
    rows = [
      [
        { content: "Date", align: :center },
        { content: "Status", align: :center },
        { content: "Activity", align: :center },
        { content: "Day", align: :center },
        { content: "Hours", align: :center },
      ]
    ]
  
    total_days = 0.0
    total_hours = 0.0
  
    generate_month_days.each do |date|
      timesheet = @timesheets.find { |t| t.date == date }
      is_weekend = date.saturday? || date.sunday?
      is_holiday = Holiday.is_holiday?(date)
      row_color = (is_weekend || is_holiday) ? "CCCCCC" : nil
  
      check_in = timesheet&.check_in
      check_out = timesheet&.check_out
  
      hours = 0.0
      if check_in && check_out
        # สร้างช่วงพักกลางวันในวันที่เดียวกันกับ check_in
        lunch_start = Time.zone.local(check_in.year, check_in.month, check_in.day, 12, 0, 0)
        lunch_end   = Time.zone.local(check_in.year, check_in.month, check_in.day, 13, 0, 0)
      
        # คำนวณเวลาที่ทับกับช่วงพักกลางวัน
        lunch_overlap = [[check_out, lunch_end].min - [check_in, lunch_start].max, 0].max
      
        # เวลาทำงานหลังหักพักเที่ยง
        work_seconds = (check_out - check_in) - lunch_overlap
        hours = (work_seconds / 3600.0).round(3)
      end
  
      day = hours > 0 ? (hours / 8.0).round(3) : 0.0
  
      total_days += day
      total_hours += hours
  
      display_day = format_float(day, floor: true)
      display_hours = format_float(hours)  # ชั่วโมงไม่ต้องปัด

  
      rows << [
        { content: format_date(date), background_color: row_color, align: :center },
        { content: safe_text(timesheet&.work_status), background_color: row_color, align: :center },
        { content: timesheet&.work_description.to_s || "", background_color: row_color },
        { content: display_day.presence || "", background_color: row_color, align: :center },
        { content: display_hours.presence || "", background_color: row_color, align: :center }
      ]
    end
  
    # รวมท้ายตาราง
    final_day = format_float(total_days, floor: true)
    final_hour = format_float(total_hours)

  
    rows << [
  { content: "Total", colspan: 3, align: :right, font_style: :bold },
  { content: final_day, align: :center, font_style: :bold },
  { content: final_hour, align: :center, font_style: :bold }
]
  
    rows
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

  def format_float(value, floor: false)
    return "" if value.nil? || value == 0
    value = value.round(3) if floor  # Use round instead of floor
    s = format("%.2f", value)
    s.sub(/\.?0+$/, '')  # Remove trailing zeros
  end
  
end
