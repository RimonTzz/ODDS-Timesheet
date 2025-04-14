class WorkdaysController < ApplicationController
  def new
    @workday = Workday.new
  end

  def create
    @workday = Workday.new(workday_params)

    if @workday.save
      redirect_to workdays_path, notice: "เพิ่มวันทำงานสำเร็จ"
    else
      render :new
    end
  end

  private

  def workday_params
    params.require(:workday).permit(:date, :hours_worked, :user_id).tap do |whitelisted|
      # ตรวจสอบว่าเป็นวันหยุดที่เป็น Exception หรือไม่
      holiday = Holiday.find_by(date: whitelisted[:date])
      if holiday&.is_exception
        # Logic สำหรับการบันทึกวันทำงานในกรณีที่เป็น Exception
        whitelisted[:is_working_day] = true
      end
    end
  end
end 