require 'dry-monads'
require_relative '../../../../core/value_objects/email'

module Adapters
  module PostgreSQL
    module Mappers
      module ValueObjects
        class Email < Core::ValueObjects::Email
          def initialize(email)
            super(email)
          end

          def self.create(email)
            self.new(email)
          end
        end
      end 
    end
  end
end