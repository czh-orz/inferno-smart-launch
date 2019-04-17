require 'inferno-fhir'
require 'dm-core'
require_relative './sequence_extension'

def self.property(name, type, default=nil)
	if default.nil? then
		Inferno::Models::TestingInstance.send("property", name, type) 
	else
		Inferno::Models::TestingInstance.send("property", name, type, default) 
	end
end

property :dynamically_registered, DataMapper::Property::Boolean


property :token_retrieved_at, DateTime
property :oauth_introspection_endpoint, String
property :resource_id, String
property :resource_secret, String
property :introspect_token, String
property :introspect_refresh_token, String
DataMapper.auto_upgrade!


Inferno::Sequence::SequenceBase.send("include", SequenceExtension)

Inferno::Sequence.load_sequences(__dir__)
Inferno::Module.load_modules(__dir__)

Inferno::App::Endpoint::Landing.send("set", :modules, ['smart'])