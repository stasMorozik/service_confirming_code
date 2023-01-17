require 'dry-monads'
require_relative 'value_objects/email'

module Core
  class Entity
    include Dry::Monads[:result]

    attr_reader :email
    attr_reader :code
    attr_reader :confirmed
    attr_reader :created

    private_class_method :new

    def initialize(email)
      @value = email
      @code = rand(1000...9999)
      @confirmed = false
      @created = Time.now.to_i + 900
    end

    def self.create(email)
      result = Core::ValueObjects::Email.create(email)
      
      if result.failure?
        return result
      end

      result.bind do |email| 
        Dry::Monads::Success(new(email))
      end
    end

    def confirm(code)
      unless code.instance_of? Integer
        return Dry::Monads::Failure('Invalid code')
      end
      
      unless code == @code 
        return Dry::Monads::Failure('Wrong code') 
      end

      @confirmed = true

      Dry::Monads::Success(true)
    end

    def is_confirmed
      unless @confirmed
        return Dry::Monads::Failure('Code is not confirmed')
      end
  
      Dry::Monads::Success(true)
    end
  
    def is_alive
      if Time.now.to_i >= @created
        return Dry::Monads::Failure('Code is not confirmed')
      end
  
      Dry::Monads::Success(true)
    end
  end
end