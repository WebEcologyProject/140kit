class Whitelisting
  include DataMapper::Resource
  property :hostname, String, :key => true
  property :ip, String
  property :whitelisted, Boolean, :default => 0
end