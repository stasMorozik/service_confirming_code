require 'dry-monads'
require_relative '../entity'
require_relative '../value_objects/email'

module Core
  module UseCases
    class Confirming
      include Dry::Monads[:result, :maybe]

      attr_reader :getting_port
      attr_reader :updating_port

      protected :getting_port
      protected :updating_port

      def initialize(getting_port, updating_port)
        @getting_port = getting_port
        @updating_port = updating_port
      end

      def confirm(email, code)
        result_email = Core::ValueObjects::Email.create(email)

        if result_email.failure?
          return result_email
        end

        maybe_entity = result_email.bind do |email|
          @getting_port.get(email)
        end

        if maybe_entity.failure?
          return maybe_entity
        end

        maybe_entity.bind do |entity|
          result_confirmed = entity.confirm(code)

          if result_confirmed.failure?
            return result_confirmed
          end

          @updating_port.update(entity)
        end
      end
    end
  end
end
