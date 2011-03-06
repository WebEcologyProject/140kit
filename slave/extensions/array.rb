class Array
  def sum
    self.compact.inject(0) { |s,v| s += v }
  end
  def to_i
    self.collect{|x| x.to_i}
  end
  def to_f
    self.collect{|x| x.to_i}
  end
  def frequencies
    new_val = {}
    self.each do |s|
      elem = s.to_s
      new_val[elem].nil? ? new_val[elem]=1 : new_val[elem]+=1
    end
    return new_val
  end
  def chunk(pieces=2)
    len = self.length;
    mid = (len/pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start+mid
      last = last-1 unless len%pieces >= i
      chunks << self[start..last] || []
      start = last+1
    end
    chunks
  end
end