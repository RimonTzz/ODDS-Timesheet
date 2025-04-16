class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :authorize_not_user!

  # GET /clients or /clients.json
  def index
    @clients = Client.order(id: :asc)
  end

  # GET /clients/1 or /clients/1.json
  def show
    respond_to do |format|
      format.json { render json: @client }
    end
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients or /clients.json
  def create
    @client = Client.new(client_params)
    
    respond_to do |format|
      if @client.save
        format.turbo_stream { success_turbo_stream("Client was successfully created.", clients_path) }
        format.html { redirect_to clients_path, notice: "Client was successfully created." }
      else
        format.turbo_stream { error_turbo_stream("Failed to create client.") }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)
        format.turbo_stream { success_turbo_stream("Client was successfully updated.", clients_path) }
        format.html { redirect_to clients_path, notice: "Client was successfully updated." }
      else
        format.turbo_stream { error_turbo_stream("Failed to update client.") }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    # Remove client reference from all related sites before destroying
    @client.sites.update_all(client_id: nil)
    respond_to do |format|
      if @client.destroy
        format.turbo_stream { success_turbo_stream("Client was successfully deleted.", clients_path) }
        format.html { redirect_to clients_path, notice: "Client was successfully deleted." }
      else
        format.turbo_stream { error_turbo_stream("Failed to delete client.", clients_path) }
        format.html { redirect_to clients_path, alert: "Failed to delete client." }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.require(:client).permit(:client_name, :contact_info)
    end
end
