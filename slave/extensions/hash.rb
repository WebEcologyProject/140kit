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
  
  def highest
    high_pair = self.max {|a,b| a[1] <=> b[1]}
    return {high_pair[0] => high_pair[1]}
  end
  
  def lowest
    low_pair = self.min {|a,b| a[1] <=> b[1]}
    return {low_pair[0] => low_pair[1]}
  end
  
end