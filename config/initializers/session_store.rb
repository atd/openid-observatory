# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_openid-observatory',
  :secret      => '663ae2e097412da24b2e255443c9ba32abf09abb1474621ad53b9ffac2b7d3b29c0cf60501b15e2989e01fc14b997d57379d491c8debaaf58df0276837295fec'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
