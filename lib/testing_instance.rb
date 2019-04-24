module Inferno
  module Models
    class TestingInstance
      property :dynamically_registered, DataMapper::Property::Boolean


      property :token_retrieved_at, DateTime
      property :oauth_introspection_endpoint, String
      property :resource_id, String
      property :resource_secret, String
      property :introspect_token, String
      property :introspect_refresh_token, String
      DataMapper.auto_upgrade!
    end
  end
end