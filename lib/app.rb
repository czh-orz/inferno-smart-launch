require 'inferno-fhir'
require 'dm-core'
require_relative './testing_instance'

DataMapper.auto_upgrade!
Inferno::Sequence.load_sequences(__dir__)
Inferno::Module.load_modules(__dir__)

Inferno::App::Endpoint::Landing.send("set", :modules, ['smart'])
Rack::Handler::Thin.run Inferno::App.new