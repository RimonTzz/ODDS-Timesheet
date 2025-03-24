require "prawn"
require "prawn/table"

class ProjectTimesheetPdf < Prawn::Document
  def initialize(project, date)
    super(
      page_size: "A4",
      margin: [ 50, 50, 50, 50 ],
      info: {
        Title: "Timesheet Report",
        Author: "Timesheet App",
        Subject: "Project Timesheet Report",
        Keywords: "timesheet, report",
        CreationDate: Time.now
      }
    )

    # Add UTF-8 font
    font_families.update(
      "Sarabun" => {
        normal: Rails.root.join("app/assets/fonts/Sarabun-Regular.ttf"),
        bold: Rails.root.join("app/assets/fonts/Sarabun-Bold.ttf")
      }
    )
    font "Sarabun"

    @project = project
    @date = date
    @site = project.site
    @month = date.strftime("%B %Y")

    setup_header
    project_info
    generate_tables
  end

  private

  def setup_header
    text "รายงานการทำงาน", size: 20, style: :bold, align: :center
    move_down 20
  end

  def project_info
    text "โปรเจ็ค: #{@project.project_name}", size: 14, style: :bold
    text "ไซต์: #{@site.site_name}", size: 12
    text "เดือน: #{@month}", size: 12
    text "จำนวนพนักงาน: #{@project.user_projects.count} คน", size: 12
    move_down 20
  end

  def generate_tables
    @project.user_projects.each do |user_project|
      user = user_project.user
      timesheets = user.timesheets.where(user_project_id: user_project.id, date: @date.beginning_of_month..@date.end_of_month)

      # Start new page for each user
      start_new_page unless page_number == 1

      text "พนักงาน: #{user.first_name} #{user.last_name}", size: 14, style: :bold
      move_down 10

      # Create table for timesheet data
      table_data = [ [ "วันที่", "เวลาเข้างาน", "เวลาออกงาน", "สถานะ", "รายละเอียด" ] ]

      timesheets.each do |timesheet|
        table_data << [
          timesheet.date.strftime("%d/%m/%Y"),
          timesheet.check_in&.strftime("%H:%M"),
          timesheet.check_out&.strftime("%H:%M"),
          timesheet.work_status,
          timesheet.work_description
        ]
      end

      # Add summary row
      total_work_days = timesheets.where(work_status: "work").count
      total_leave_days = timesheets.where(work_status: "leave").count
      table_data << [ "", "", "", "", "" ]
      table_data << [ "จำนวนวันทำงาน", total_work_days, "", "", "" ]
      table_data << [ "จำนวนวันลา", total_leave_days, "", "", "" ]

      table(table_data, header: true, width: bounds.width) do |t|
        t.row(0).style(background_color: "CCCCCC", text_color: "000000", font_style: :bold)
        t.cells.style(size: 10)
        t.cells.padding = 5
        t.cells.borders = [ :bottom, :left, :right, :top ]
      end

      move_down 20
    end
  end
end
