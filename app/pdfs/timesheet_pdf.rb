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
    bounding_box([0, cursor], width: bounds.width) do
      # Left-side header text
      bounding_box([0, cursor], width: bounds.width - 160) do
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
  
      # Right-side logo
      logo_path = Rails.root.join("app/assets/images/icon/ODT_logo.png")
      if File.exist?(logo_path)
        bounding_box([bounds.right - 80, cursor + 85], width: 150) do
          image logo_path, width: 75
        end
      end
    end
  
    move_down 50  # spacing after header+logo block
  end
  
  def table_content
    column_widths = [110, 50, 50, 100, 230]  # กำหนดขนาดของแต่ละคอลัมน์
  
    # กำหนดตาราง
    table timesheet_rows, width: bounds.width, column_widths: column_widths do
      row(0).font_style = :bold
      row(0).background_color = "CCCCCC"
      self.header = true
      cells.padding_right = 2
      cells.borders = [:bottom, :left, :right, :top]
    end

    # ขยับตำแหน่งให้ห่างจากตาราง 100px
    move_down 50  # ระยะห่างจากตาราง 100px

    # เก็บตำแหน่ง cursor ไว้สำหรับทั้งสองช่อง
    signature_y = cursor

    # ช่องเซ็นลายเซ็นต์ "Approve By (Client 1)" ซ้าย
    bounding_box([0, signature_y], width: bounds.width / 2 - 10, height: 110) do
      text "Initial By (Odd-e)", align: :center, valign: :top
      move_down 50  # เพิ่มระยะห่างระหว่างข้อความกับเส้น
      stroke_horizontal_rule
      move_down 10  # ระยะห่างระหว่างเส้นกับช่องลายเซ็นต์
      text "(  #{@user_project.user.first_name} #{@user_project.user.last_name}  )", align: :center  # ช่องว่างสำหรับลายเซ็นต์
      text "date: #{Date.today.strftime('%d / %m / %Y')}", align: :center    
    end

    # ช่องเซ็นลายเซ็นต์ "Approve By (Client 2)" ขวา
    bounding_box([bounds.width / 2 + 10, signature_y], width: bounds.width / 2 - 10, height: 110) do
      text "Approve By (Client)", align: :center, valign: :top
      move_down 50  # เพิ่มระยะห่างระหว่างข้อความกับเส้น
      stroke_horizontal_rule
      move_down 10  # ระยะห่างระหว่างเส้นกับช่องลายเซ็นต์
      text "(                                                        )", align: :center  # ช่องว่างสำหรับลายเซ็นต์
      text "date:       /        /        ", align: :center    
    end
  end

  def timesheet_rows
    [["Date", "in", "out", "สถานะ", "รายละเอียด"]] +
      generate_month_days.map do |date|
        timesheet = @timesheets.find { |t| t.date == date }
        is_weekend = date.saturday? || date.sunday?
        is_holiday = Holiday.is_holiday?(date)
        row_color = (is_weekend || is_holiday) ? "EEEEEE" : nil

        [
          { content: format_date(date), background_color: row_color },
          { content: safe_time_format(timesheet&.check_in), background_color: row_color },
          { content: safe_time_format(timesheet&.check_out), background_color: row_color },
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
