module ApplicationHelper
  def month_options
    current_year = Time.current.year
    Date::MONTHNAMES.compact.map.with_index do |name, index|
      month_num = index + 1
      [ name, "#{current_year}-#{month_num.to_s.rjust(2, '0')}" ]
    end
  end
end
