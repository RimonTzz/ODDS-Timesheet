class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy export_pdf ]
  before_action :authenticate_user!
  before_action :authorize_not_user!

  # GET /projects or /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1 or /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)
    
    respond_to do |format|
      if @project.save
        format.turbo_stream { success_turbo_stream("Project was successfully created.", projects_path) }
        format.html { redirect_to projects_path, notice: "Project was successfully created." }
      else
        format.turbo_stream { error_turbo_stream("Failed to create project.") }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.turbo_stream { success_turbo_stream("Project was successfully updated.", projects_path) }
        format.html { redirect_to projects_path, notice: "Project was successfully updated." }
      else
        format.turbo_stream { error_turbo_stream("Failed to update project.") }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    begin
      if @project.timesheets.any?
        @project.destroy_with_timesheets
        respond_to do |format|
          format.turbo_stream { success_turbo_stream("Project and related timesheets were successfully deleted.", projects_path) }
          format.html { redirect_to projects_path, notice: "ลบโปรเจคและข้อมูล timesheets ที่เกี่ยวข้องสำเร็จ" }
        end
      else
        @project.destroy!
        respond_to do |format|
          format.turbo_stream { success_turbo_stream("Project was successfully deleted.", projects_path) }
          format.html { redirect_to projects_path, notice: "ลบโปรเจคสำเร็จ" }
        end
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      respond_to do |format|
        format.turbo_stream { error_turbo_stream("Failed to delete project: #{e.message}", projects_path) }
        format.html { redirect_to projects_path, alert: "ไม่สามารถลบโปรเจคได้: #{e.message}" }
      end
    end
  end

  def export_pdf
    month = params[:month].to_i
    year = params[:year].to_i
    date = Date.new(year, month, 1)

    pdf = ProjectTimesheetPdf.new(@project, date, current_user)
    send_data pdf.render,
              filename: "timesheet_#{@project.project_name.parameterize}_#{year}_#{month}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.expect(project: [ :project_name, :site_id, :check_in, :check_out ])
    end
end
