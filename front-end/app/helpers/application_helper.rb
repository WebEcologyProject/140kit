# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def sluggify(slugger)
    return slugger.gsub(/[\.]/, "-")
  end
end
