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

        maybe_entity.either(
          -> entity {
            entity.confirm(code).either(
              -> success {
                @updating_port.update(entity)
              },
              -> error {
                Dry::Monads::Failure(error)
              }
            )
          },
          -> error {
            Dry::Monads::Failure(error)
          }
        )
      end
    end
  end
end
