require 'dry-monads'
require_relative 'value_objects/email'
require_relative '../../../core/entity'

module Adapters 
  module PostgreSQL
    module Mappers
      class Entity < Core::Entity
        def initialize(email, code, created, confirmed)
          super(email)
          @code = code
          @confirmed = confirmed
          @created = created
        end

        def self.create(email, code, created, confirmed)
          self.new(
            Adapters::PostgreSQL::Mappers::ValueObjects::Email.create(email), 
            code, 
            created, 
            confirmed
          )
        end
      end 
    end
  end
end
