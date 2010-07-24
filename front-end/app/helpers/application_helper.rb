# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def sluggify(slugger)
    return slugger.gsub(/[\.]/, "-")
  end
  
  def number_to_month(number)
    case number.to_i
    when 1
      return "January"
    when 2
      return "February"
    when 3
      return "March"
    when 4
      return "April"
    when 5
      return "May"
    when 6
      return "June"
    when 7
      return "July"
    when 8
      return "August"
    when 9
      return "September"
    when 10
      return "October"
    when 11
      return "November"
    when 12
      return "December"
    end                                           
  end
end
