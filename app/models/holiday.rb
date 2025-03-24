class Holiday < ApplicationRecord
  validates :date, presence: true, uniqueness: true
  validates :name, presence: true
  validates :is_bank_holiday, inclusion: { in: [ true, false ] }
  validates :is_exception, inclusion: { in: [ true, false ] }

  scope :bank_holidays, -> { where(is_bank_holiday: true) }
  scope :exceptions, -> { where(is_exception: true) }
  scope :active, -> { where("date >= ?", Date.current.beginning_of_year) }

  def self.is_holiday?(date)
    return true if date.saturday? || date.sunday?
    return false if exceptions.exists?(date: date)
    bank_holidays.exists?(date: date)
  end
end
