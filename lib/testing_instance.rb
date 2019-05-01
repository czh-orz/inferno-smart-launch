module Inferno
    module Models
      class TestingInstance
        property :dynamically_registered, Boolean


        property :token_retrieved_at, DateTime
        property :oauth_introspection_endpoint, String
        property :resource_id, String
        property :resource_secret, String
        property :introspect_token, String
        property :introspect_refresh_token, String

        

        add_property_input(:oauth_register_endpoint, 'OAuth 2.0 Dynamic Registration Bearer Token (optional)')
        add_property_input(:oauth_authorize_endpoint, 'OAuth 2.0 Authorize Endpoint')
        add_property_input(:client_id, 'Client ID')
        add_property_input(:dynamic_registration_token, 'OAuth 2.0 Dynamic Registration Bearer Token (optional)')
        add_property_input(:confidential_client, 'Confidential Client', false, true)
        add_property_input(:client_secret, 'Client Secret')
        add_property_input(:client_name, 'OAuth Client Name')
        add_property_input(:scopes, 'Scopes')
        add_property_input(:token, 'Bearer Token')
        add_property_input(:patient_id, 'Patient ID')
        add_property_input(:id_token, 'OAuth 2.0 ID Token')
        add_property_input(:refresh_token, 'Refresh Token')
        add_property_input(:initiate_login_uri, 'Launch URI', true)
        add_property_input(:redirect_uris, 'Redirect URI', true)
        
        def save_supported_resources(conformance)

            resources = ['Patient',
                         'AllergyIntolerance',
                         'CarePlan',
                         'Condition',
                         'Device',
                         'DiagnosticReport',
                         'DocumentReference',
                         'ExplanationOfBenefit',
                         'Goal',
                         'Immunization',
                         'Medication',
                         'MedicationDispense',
                         'MedicationStatement',
                         'MedicationOrder',
                         'Observation',
                         'Procedure',
                         'DocumentReference',
                         'Provenance']
    
            supported_resources = conformance.rest.first.resource.select{ |r| resources.include? r.type}.reduce({}){|a,k| a[k.type] = k; a}
    
            self.supported_resources.each(&:destroy)
            self.save!
    
            resources.each_with_index do |resource_name, index|
    
              resource = supported_resources[resource_name]
    
              read_supported = resource && resource.interaction && resource.interaction.any?{|i| i.code == 'read'}
    
              self.supported_resources << SupportedResource.create({
                                                                       resource_type: resource_name,
                                                                       index: index,
                                                                       testing_instance_id: self.id,
                                                                       supported: !resource.nil?,
                                                                       read_supported: read_supported,
                                                                       vread_supported: resource && resource.interaction && resource.interaction.any?{|i| i.code == 'vread'},
                                                                       search_supported: resource && resource.interaction && resource.interaction.any?{|i| i.code == 'search-type'},
                                                                       history_supported: resource && resource.interaction && resource.interaction.any?{|i| i.code == 'history-instance'}
                                                                   })
            end
    
            self.save!
    
          end
    
          def conformance_supported?(resource, methods = [])
    
            resource_support = self.supported_resources.find {|r| r.resource_type == resource.to_s}
            return false if resource_support.nil? || !resource_support.supported
    
            methods.all? do |method|
              case method
              when :read
                resource_support.read_supported
              when :search
                resource_support.search_supported
              when :history
                resource_support.history_supported
              when :vread
                resource_support.vread_supported
              else
                false
              end
            end
          end
    
          def post_resource_references(resource_type: nil, resource_id: nil)
            self.resource_references.each do |ref|
              if (ref.resource_type == resource_type) && (ref.resource_id == resource_id)
                ref.destroy
              end
            end
            self.resource_references << ResourceReference.new({resource_type: resource_type,
                                                              resource_id: resource_id})
            self.save!
            # Ensure the instance resource references are accurate
            self.reload
          end
      end
    end
end