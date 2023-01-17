require 'dry-monads'

module Core

  module ValueObjects
    class Email
      
      include Dry::Monads[:result]

      attr_accessor :value
      private_class_method :new

      def initialize(email)
        @value = email
      end
  
      def self.create(email)
        unless email.instance_of? String
          return Dry::Monads::Failure('Invalid email address')
        end
  
        unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match(email)
          return Dry::Monads::Failure('Invalid email address')
        end
  
        Dry::Monads::Success(new(email))
      end
    end
  end
end