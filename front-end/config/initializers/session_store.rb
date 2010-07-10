# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails-end_session',
  :secret      => 'd87f0c4be45f382bce5f30dedbabf45710d131373ee3479b0ae5d3c1738233bda8d198c547f229f89c13c87b79442a98831fd10fd55cd4833a04897da2cde26f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
