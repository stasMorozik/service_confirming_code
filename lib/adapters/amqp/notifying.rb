require 'json'
require 'dry-monads'

module Adapters
  module Amqp
    class Notifying
      include Dry::Monads[:result]

      attr_reader :queue

      protected :queue

      def initialize(queue)
        @queue = queue
      end

      def notify(email, message)
        unless email.instance_of? Core::ValueObjects::Email
          return Dry::Monads::Failure('Invalid email')
        end
  
        unless message.instance_of? String
          return Dry::Monads::Failure('Invalid message')
        end

        @queue.publish({
          :message => message,
          :email => email.value
        }.to_json)

        Dry::Monads::Success(true)
      end
    end
  end  
end