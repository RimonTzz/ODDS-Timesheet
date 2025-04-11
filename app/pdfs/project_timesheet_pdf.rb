require "prawn"
require "prawn/table"

class ProjectTimesheetPdf < Prawn::Document
  def initialize(project, date, current_user)
    super(
      page_size: "A4",
      margin: [50, 50, 50, 50],
      info: {
        Title: "Timesheet Report",
        Author: "Timesheet App",
        Subject: "Project Timesheet Report",
        Keywords: "timesheet, report",
        CreationDate: Time.now
      }
    )

    @project = project
    @date = date
    @site = project.site
    @month = date.strftime("%B %Y")
    @current_user = current_user

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
      bounding_box([0, cursor], width: bounds.width - 160) do
        text "Monthly Report", size: 20, style: :bold
        move_down 5

        formatted_text [
          { text: "Project", styles: [:bold] },
          { text: " : #{@project.project_name}" }
        ], size: 10

        formatted_text [
          { text: "Site", styles: [:bold] },
          { text: " : #{@site.site_name}" }
        ], size: 10

        formatted_text [
          { text: "Employee", styles: [:bold] },
          { text: " : #{@project.user_projects.count} people" }
        ], size: 10

        formatted_text [
          { text: "Month", styles: [:bold] },
          { text: " : #{@month}" }
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
    summary_data = [
      [
        { content: "Name" },
        { content: "Day", align: :center },
        { content: "Hours", align: :center }
      ]
    ]

    total_days = 0.0
    total_hours = 0.0

    @project.user_projects.each do |user_project|
      user = user_project.user
      timesheets = user.timesheets.where(
        user_project_id: user_project.id,
        date: @date.beginning_of_month..@date.end_of_month
      )

      user_days = 0.0
      user_hours = 0.0

      timesheets.each do |timesheet|
        check_in = timesheet.check_in
        check_out = timesheet.check_out

        hours = calculate_work_hours(check_in, check_out)
        day = calculate_day_value(hours)

        user_hours += hours
        user_days += day
      end

      total_hours += user_hours
      total_days += user_days

      summary_data << [
        "#{user.first_name} #{user.last_name}",
        format_float(user_days, floor: true),
        format_float(user_hours)
      ]
    end

    summary_data << [
      { content: "Total", font_style: :bold, align: :right },
      { content: format_float(total_days, floor: true), align: :center, font_style: :bold },
      { content: format_float(total_hours), align: :center, font_style: :bold }
    ]

    column_widths = [295.28, 100, 100]

    table summary_data, header: true, width: bounds.width, column_widths: column_widths do |t|
      t.row(0).style(background_color: "999999", font_style: :bold)
      t.row(-1).style(background_color: "CCCCCC", font_style: :bold)
      t.cells.style(size: 10)
      t.cells.padding = 5
      t.cells.borders = [:bottom, :left, :right, :top]
      t.columns(1..2).align = :center
    end

    move_down 50
    draw_signatures
  end

  def draw_signatures
    signature_y = cursor

    bounding_box([0, signature_y], width: bounds.width / 2 - 10, height: 110) do
      text "Initial By (Odd-e)", align: :center, valign: :top
      move_down 50
      stroke_horizontal_rule
      move_down 10
      text "(  #{@current_user.first_name} #{@current_user.last_name}  )", align: :center
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

  private

  def calculate_work_hours(check_in, check_out)
    return 0.0 if check_in.nil? || check_out.nil?

    lunch_start = Time.zone.local(check_in.year, check_in.month, check_in.day, 12, 0, 0)
    lunch_end   = Time.zone.local(check_in.year, check_in.month, check_in.day, 13, 0, 0)

    lunch_overlap = [[check_out, lunch_end].min - [check_in, lunch_start].max, 0].max
    work_seconds = (check_out - check_in) - lunch_overlap

    (work_seconds / 3600.0).round(3)
  end

  def calculate_day_value(hours)
    return 0.0 if hours.nil? || hours <= 0
    (hours / 8.0).round(3)
  end
  

  def format_float(value, floor: false)
    return "" if value.nil? || value == 0
    value = value.round(3) if floor
    s = format("%.2f", value)
    s.sub(/\.?0+$/, '')
  end
end
