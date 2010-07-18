class String
  def to_bool
    case self.downcase
    when "true"
      return true
    when "false"
      return false
    else
      return nil
    end
  end
  
  def to_url
    stripped_url = self.match(/^(https?:\/\/)?(www\.)?(.*)$/i)[3]
    s = self[0,8] == "https://" ? "s" : ""
    return "http#{s}://#{stripped_url}"
  end
end

class TrueClass
  def to_i
    return 1
  end
end

class FalseClass
  def to_i
    return 0
  end
end

class Fixnum
  def to_bool
    return self > 0 ? true : false
  end
end