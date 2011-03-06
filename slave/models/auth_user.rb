class AuthUser
  include DataMapper::Resource
  property :id, Serial
  property :user_name, String
  property :password, String
  property :instance_id, String
  property :hostname, String
end