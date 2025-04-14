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

    if @site.save
      redirect_to sites_path
    else
      render :new
    end
  end

  # PATCH/PUT /sites/1 or /sites/1.json
  def update
    @site = Site.find(params[:id])
    if @site.update(site_params)
      redirect_to sites_path
    else
      render :edit
    end
  end

  # DELETE /sites/1 or /sites/1.json
  def destroy
    @site.destroy!

    respond_to do |format|
      format.html { redirect_to sites_path, status: :see_other, notice: "Site was successfully destroyed." }
      format.json { head :no_content }
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
