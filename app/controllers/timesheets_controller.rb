class TimesheetsController < ApplicationController
  include Devise::Controllers::Helpers
  include ApplicationHelper
  before_action :authenticate_user!
  before_action :set_user_projects
  before_action :set_timesheet, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_not_user!, only: [ :edit, :update, :destroy ]

  def index
    @timesheets = current_user.timesheets.includes(:user_project)
    @months = month_options
    # ถ้าไม่มี project ให้ใช้ค่าเริ่มต้น
    @selected_user_project_id = params[:user_project_id]
    unless @selected_user_project_id
      @selected_user_project_id = @user_projects.order(:id).first&.id
    end

    @user_project = UserProject.find_by(id: @selected_user_project_id)

    # กำหนดค่า month
    @selected_month = if params[:month].present?
      begin
        # ตรวจสอบว่า month ที่ส่งมาเป็นรูปแบบที่ถูกต้องหรือไม่
        if params[:month].match?(/\A\d{4}-\d{2}\z/)
          year, month = params[:month].split("-").map(&:to_i)
          Date.new(year, month, 1) # ทดสอบว่าสามารถสร้างวันที่ได้หรือไม่
          params[:month]
        else
          Time.current.strftime("%Y-%m")
        end
      rescue ArgumentError
        Time.current.strftime("%Y-%m")
      end
    else
      Time.current.strftime("%Y-%m")
    end

    if @user_project
      begin
        # สร้าง array ของวันที่ในเดือนที่เลือก
        year, month = @selected_month.split("-").map(&:to_i)
        @timesheet_days = (Date.new(year, month, 1)..Date.new(year, month, -1)).to_a

        # ดึงข้อมูล timesheet ที่มีอยู่แล้ว
        @existing_timesheets = @user_project.timesheets
                                        .where(date: @timesheet_days)
                                        .index_by(&:date)
      rescue ArgumentError
        # ถ้าเกิด error ให้ใช้เดือนปัจจุบัน
        current_date = Time.current
        @selected_month = current_date.strftime("%Y-%m")
        @timesheet_days = (Date.new(current_date.year, current_date.month, 1)..Date.new(current_date.year, current_date.month, -1)).to_a
        @existing_timesheets = @user_project.timesheets
                                        .where(date: @timesheet_days)
                                        .index_by(&:date)
      end
    end
  end

  def show
  end

  def new
    @user_project = UserProject.find_by(id: params[:user_project_id])
    @months = month_options

    # ถ้าไม่มี project ให้ใช้ค่าเริ่มต้น
    unless @user_project
      @user_project = @user_projects.order(:id).first
    end

    # กำหนดค่า month
    @selected_month = if params[:month].present?
      begin
        # ตรวจสอบว่า month ที่ส่งมาเป็นรูปแบบที่ถูกต้องหรือไม่
        if params[:month].match?(/\A\d{4}-\d{2}\z/)
          year, month = params[:month].split("-").map(&:to_i)
          Date.new(year, month, 1) # ทดสอบว่าสามารถสร้างวันที่ได้หรือไม่
          params[:month]
        else
          Time.current.strftime("%Y-%m")
        end
      rescue ArgumentError
        Time.current.strftime("%Y-%m")
      end
    else
      Time.current.strftime("%Y-%m")
    end

    if @user_project
      begin
        # สร้าง array ของวันที่ในเดือนที่เลือก
        year, month = @selected_month.split("-").map(&:to_i)
        @timesheet_days = (Date.new(year, month, 1)..Date.new(year, month, -1)).to_a

        # ดึงข้อมูล timesheet ที่มีอยู่แล้ว
        @existing_timesheets = @user_project.timesheets
                                          .where(date: @timesheet_days)
                                          .index_by(&:date)
      rescue ArgumentError
        # ถ้าเกิด error ให้ใช้เดือนปัจจุบัน
        current_date = Time.current
        @selected_month = current_date.strftime("%Y-%m")
        @timesheet_days = (Date.new(current_date.year, current_date.month, 1)..Date.new(current_date.year, current_date.month, -1)).to_a
        @existing_timesheets = @user_project.timesheets
                                          .where(date: @timesheet_days)
                                          .index_by(&:date)
      end
    end
  end

  def edit
  end

  def create
    @user_project = UserProject.find(params[:user_project_id])
    @selected_month = params[:month]
    @months = month_options

    year, month = @selected_month.split("-").map(&:to_i)
    @timesheet_days = (Date.new(year, month, 1)..Date.new(year, month, -1)).to_a

    @existing_timesheets = @user_project.timesheets
                                    .where(date: @timesheet_days)
                                    .index_by(&:date)

    if params[:timesheet].present?
      success = true
      error_message = nil
      
      @user_project.transaction do
        params[:timesheet].each do |day, data|
          next if data[:check_in].blank? && data[:check_out].blank? && 
                 data[:work_status].to_s.empty? && data[:description].blank?

          date = Date.new(year, month, day.to_i)
          timesheet = @user_project.timesheets.find_or_initialize_by(date: date)
          
          timesheet.assign_attributes(
            check_in: data[:check_in],
            check_out: data[:check_out],
            work_status: data[:work_status].presence,
            work_description: data[:description]
          )

          unless timesheet.save
            success = false
            error_message = timesheet.errors.full_messages.join(", ")
            break
          end
        end
      end

      respond_to do |format|
        format.turbo_stream do
          if success
            render turbo_stream: turbo_stream.update("flash", <<-HTML.strip_heredoc)
              <div class="alert-sticky" id="alert-message">
                <div class="alert-container alert-success">
                  <div class="alert-flex">
                    <div class="alert-icon alert-icon-success">
                      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-5 w-5">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                      </svg>
                    </div>
                    <div class="alert-content">
                      <p class="alert-text alert-text-success">Save time sheet done!</p>
                    </div>
                  </div>
                </div>
              </div>
              <script>
                (() => {
                  const alert = document.getElementById('alert-message');
                  if (alert) {
                    setTimeout(() => {
                      alert.classList.add('fade-out');
                      setTimeout(() => {
                        alert.remove();
                      }, 500);
                    }, 3000);
                  }
                })();
              </script>
            HTML
          else
            render turbo_stream: turbo_stream.update("flash", <<-HTML.strip_heredoc)
              <div class="alert-sticky" id="alert-message">
                <div class="alert-container alert-error">
                  <div class="alert-flex">
                    <div class="alert-icon alert-icon-error">
                      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-5 w-5">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                      </svg>
                    </div>
                    <div class="alert-content">
                      <p class="alert-text alert-text-error">#{error_message || 'Have error your time sheet not save'}</p>
                    </div>
                  </div>
                </div>
              </div>
              <script>
                (() => {
                  const alert = document.getElementById('alert-message');
                  if (alert) {
                    setTimeout(() => {
                      alert.classList.add('fade-out');
                      setTimeout(() => {
                        alert.remove();
                      }, 500);
                    }, 3000);
                  }
                })();
              </script>
            HTML
          end
        end
        format.html do
          if success
            redirect_to timesheets_path(user_project_id: @user_project.id, month: @selected_month), 
              notice: "Save time sheet done!"
          else
            render :index, status: :unprocessable_entity
          end
        end
      end
    else
      flash.now[:alert] = "กรุณากรอกข้อมูลอย่างน้อย 1 วัน"
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @timesheet.update(timesheet_params)
      redirect_to @timesheet, notice: "อัพเดทข้อมูลสำเร็จ"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @timesheet.destroy
    redirect_to timesheets_path, notice: "ลบข้อมูลสำเร็จ"
  end

  def data
    user_project = UserProject.find(params[:user_project_id])
    month = params[:month].to_i
    start_date = Date.new(Date.today.year, month, 1)
    end_date = start_date.end_of_month

    @timesheets = Timesheet.where(user_project: user_project, date: start_date..end_date)
    render json: @timesheets
  end

  def export_pdf
    @user_project = UserProject.find(params[:user_project_id])
    @selected_month = params[:month]
    
    year, month = @selected_month.split("-").map(&:to_i)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    @timesheets = @user_project.timesheets.where(date: start_date..end_date)
    
    respond_to do |format|
      format.pdf do
        pdf = TimesheetPdf.new(@timesheets, @user_project, @selected_month)
        send_data pdf.render, 
                  filename: "timesheet_#{@user_project.project.project_name}_#{@selected_month}.pdf", 
                  type: "application/pdf", 
                  disposition: "inline"
      end
    end
  end

  def timesheet_data
    user_project_id = params[:user_project_id]
    month = params[:month].to_i
    user_project = current_user.user_projects.find(user_project_id)
    start_date = Date.new(Date.today.year, month, 1)
    end_date = start_date.end_of_month
    @timesheets = Timesheet.where(user: current_user, project: user_project.project, date: start_date..end_date)
    render json: { timesheets: @timesheets.map { |t| { date: t.date, check_in: t.check_in, check_out: t.check_out, work_status: t.work_status } } }
  end

  private

  def set_user_projects
    @user_projects = current_user.user_projects.includes(:project)
  end

  def set_timesheet
    @timesheet = Timesheet.find(params[:id])
  end

  def timesheet_params
    params.require(:timesheet).permit(:user_project_id, :date, :check_in, :check_out, :work_status, :notes)
  end

  def authorize_not_user!
    unless current_user.admin?
      redirect_to timesheets_path, alert: "คุณไม่มีสิทธิ์ในการดำเนินการนี้"
    end
  end
end
