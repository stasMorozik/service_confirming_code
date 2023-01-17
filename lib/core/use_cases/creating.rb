require_relative 'entity'
require_relative 'value_objects/email'

module Core
  module UseCases
    class Creating
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
        result = Core::ValueObjects::Email.create(email)

        if result.failure?
          return result
        end

        result = @getting_port.get(email)

        if result.succes?
          
        end
      end
    end
  end
end