module ApplicationHelper
  def month_options
    Date::MONTHNAMES.compact.map.with_index { |name, index| [name, index + 1] }
  end
end