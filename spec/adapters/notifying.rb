require 'dry-monads'
require 'core/value_objects/email'

module Adapters
  class Notifying
    include Dry::Monads[:maybe, :result]

    def notify(email, message)
      unless email.instance_of? Core::ValueObjects::Email
        return Dry::Monads::Failure('Invalid email')
      end

      unless message.instance_of? String
        return Dry::Monads::Failure('Invalid message')
      end

      puts message

      return Dry::Monads::Success(true)
    end
  end
end