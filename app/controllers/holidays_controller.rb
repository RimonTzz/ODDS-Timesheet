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

    if @holiday.save
      redirect_to holidays_path, notice: "วันหยุดถูกเพิ่มเรียบร้อยแล้ว"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @holiday.update(holiday_params)
      redirect_to holidays_path, notice: "วันหยุดถูกอัพเดทเรียบร้อยแล้ว"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @holiday.destroy
    redirect_to holidays_path, notice: "วันหยุดถูกลบเรียบร้อยแล้ว"
  end

  private

  def set_holiday
    @holiday = Holiday.find(params[:id])
  end

  def holiday_params
    params.require(:holiday).permit(:date, :name, :is_bank_holiday, :is_exception, :description)
  end
end
