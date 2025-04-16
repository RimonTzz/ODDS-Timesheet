class HolidaysController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_holiday, only: [ :show, :edit, :update, :destroy ]

  def index
    @holidays = Holiday.active.order(date: :asc)
  end

  def show
  end

  def new
    @holiday = Holiday.new
  end

  def edit
  end

  def create
    @holiday = Holiday.new(holiday_params)
    
    respond_to do |format|
      if @holiday.save
        format.turbo_stream { success_turbo_stream("Holiday was successfully created.", holidays_path) }
        format.html { redirect_to holidays_path, notice: "Holiday was successfully created." }
      else
        format.turbo_stream { error_turbo_stream("Failed to create holiday.") }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @holiday.update(holiday_params)
        format.turbo_stream { success_turbo_stream("Holiday was successfully updated.", holidays_path) }
        format.html { redirect_to holidays_path, notice: "วันหยุดถูกอัพเดทเรียบร้อยแล้ว" }
      else
        format.turbo_stream { error_turbo_stream("Failed to update holiday.") }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @holiday.destroy
        format.turbo_stream { success_turbo_stream("Holiday was successfully deleted.", holidays_path) }
        format.html { redirect_to holidays_path, notice: "วันหยุดถูกลบเรียบร้อยแล้ว" }
      else
        format.turbo_stream { error_turbo_stream("Failed to delete holiday.", holidays_path) }
        format.html { redirect_to holidays_path, alert: "Failed to delete holiday." }
      end
    end
  end

  private

  def set_holiday
    @holiday = Holiday.find(params[:id])
  end

  def holiday_params
    params.require(:holiday).permit(:date, :name, :is_bank_holiday, :is_exception, :description)
  end
end
