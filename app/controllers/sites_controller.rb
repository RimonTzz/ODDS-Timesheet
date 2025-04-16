class SitesController < ApplicationController
  before_action :set_site, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :authorize_not_user!

  # GET /sites or /sites.json
  def index
    @sites = Site.all
  end

  # GET /sites/1 or /sites/1.json
  def show
  end

  # GET /sites/new
  def new
    @site = Site.new
  end

  # GET /sites/1/edit
  def edit
  end

  # POST /sites or /sites.json
  def create
    @site = Site.new(site_params)
    
    respond_to do |format|
      if @site.save
        format.turbo_stream { success_turbo_stream("Site was successfully created.", sites_path) }
        format.html { redirect_to sites_path, notice: "Site was successfully created." }
      else
        format.turbo_stream { error_turbo_stream("Failed to create site.") }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sites/1 or /sites/1.json
  def update
    respond_to do |format|
      if @site.update(site_params)
        format.turbo_stream { success_turbo_stream("Site was successfully updated.", sites_path) }
        format.html { redirect_to sites_path, notice: "Site was successfully updated." }
      else
        format.turbo_stream { error_turbo_stream("Failed to update site.") }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1 or /sites/1.json
  def destroy
    respond_to do |format|
      if @site.destroy
        format.turbo_stream { success_turbo_stream("Site was successfully deleted.", sites_path) }
        format.html { redirect_to sites_path, notice: "Site was successfully deleted." }
      else
        format.turbo_stream { error_turbo_stream("Failed to delete site.", sites_path) }
        format.html { redirect_to sites_path, alert: "Failed to delete site." }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = Site.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def site_params
      params.expect(site: [ :site_name, :location, :client_id ])
    end
end
