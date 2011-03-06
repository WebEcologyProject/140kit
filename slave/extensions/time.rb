class Time
  def self.ntp
    return self.at(self.now.to_f + TIME_OFFSET)
  end
end