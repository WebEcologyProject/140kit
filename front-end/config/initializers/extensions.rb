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
  
  def to_table
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").downcase.concat("s")
  end
  
  def sanitize_for_streaming
    # return self.split("").reject {|c| c.match(/[\w\'\-]/).nil?}.to_s
    return self.gsub(/[\'\"#]/, '').gsub(' ', '%20')
  end
  
end

class Hash
  def flat_each(prefix=[], &blk)
    each do |k,v|
      if v.is_a?(Hash)
        v.flat_each(prefix+[k], &blk)
      else
        yield prefix+[k], v
      end
    end
  end
  
  def flatify
    hh = {}
    self.to_enum(:flat_each).collect { |k,v| [k.join("-"),v] }.collect {|attrib| hh[attrib[0]] = attrib[1]}
    return hh
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