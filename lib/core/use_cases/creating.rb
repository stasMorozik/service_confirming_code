require 'dry-monads'
require_relative '../entity'
require_relative '../value_objects/email'

module Core
  module UseCases
    class Creating
      include Dry::Monads[:result, :maybe]

      attr_reader :getting_port
      attr_reader :creating_port
      attr_reader :notifying_port

      protected :getting_port
      protected :creating_port
      protected :notifying_port

      def initialize(getting_port, creating_port, notifying_port)
        @getting_port = getting_port
        @creating_port = creating_port
        @notifying_port = notifying_port
      end

      def create(email)
        result_email = Core::ValueObjects::Email.create(email)

        if result_email.failure?
          return result_email
        end

        maybe_entity = result_email.bind do |email|
          @getting_port.get(email)
        end

        result_lifetime = if maybe_entity.success?
          maybe_entity.bind do |entity|
            result_is_confirmed = entity.is_confirmed()

            if result_is_confirmed.failure?
              return entity.lifetime()
            end

            result_is_confirmed
          end
        end
        
        if result_lifetime
          if result_lifetime.failure?
            return result_lifetime
          end
        end

        result_email.bind do |email|
          result_entity = Core::Entity.create(email)

          result_entity.bind do |confirmation_code|
            result_created = @creating_port.create(confirmation_code)

            if result_created.failure?
              return result_created
            end

            @notifying_port.notify(email, "Hello! Your Code is #{confirmation_code.code}.")
            
            Dry::Monads::Success(true)
          end
        end
      end
    end
  end
end