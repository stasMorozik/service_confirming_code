require_relative 'entity'

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

      def update(email, code)
        result_email = Core::ValueObjects::Email.create(email)

        if result_email.failure?
          return result_email
        end

        maybe_entity = result_email.bind do |email|
          @getting_port.get(email)
        end

        case maybe_entity
        when Some then
          maybe_entity.bind do |entity|
            result_confirmed = entity.confirm(code)
            case result_confirmed
            when Failure then result_confirmed
            when Success then @updating_port.update(entity)
            end
          end
        when None
          Failure('Confirmation code not found')
        end
      end
    end
  end
end