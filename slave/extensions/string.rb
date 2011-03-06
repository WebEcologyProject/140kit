class String

  require 'rubygems'
  require 'htmlentities'

  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").downcase.concat("s")
  end
  
  def to_table
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").downcase.concat("s")
  end
  
  def to_bool
    if self == "1"
      return true
    elsif self == "0"
      return false
    else return nil
    end
  end
  
  def sanitize
    coder = HTMLEntities.new
    return coder.encode(self).gsub("#", "%23").gsub(" ", "%20").gsub("&quot\;", "%22").gsub("\"", "%22").gsub("\342\231\245", "&#9829\;")
  end
  
  def sanitize_for_streaming
    # return self.split("").reject {|c| c.match(/[\w\'\-]/).nil?}.to_s
    return self.gsub(/[\'\"#]/, '').gsub(' ', '%20')
  end
  
  def classify
    if self.split(//).last == "s"
      camelize(self.sub(/.*\./, '').chop)
    else
      camelize(self.sub(/.*\./, ''))
    end
  end
  
  def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end
  
  def constantize
    return Object.const_defined?(self) ? Object.const_get(self) : Object.const_missing(self)
  end
  
  def super_strip
    #This regexp is used in place of \W to allow for # and @ signs.
     if self.include?("#") || self.include?("@")
       return self
     elsif self.include?("http")
       return self
     else
       return self.strip.downcase.gsub(/[!$%\*&:.\;{}\[\]\(\)\-\_+=\'\"\|<>,\/?~`]/, "")
     end
  end
  
  def super_split(split_char)
    #This regexp is used in place of \W to allow for # and @ signs.
    return self.gsub(/[!$%\*\;{}\[\]\(\)\+=\'\"\|<>,~`]/, " ").split(split_char)
  end
end