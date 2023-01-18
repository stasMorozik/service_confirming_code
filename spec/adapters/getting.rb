require 'dry-monads'
require 'core/entity'
require 'core/value_objects/email'

module Adapters
  class Gettign
    include Dry::Monads[:maybe]

    attr_reader :confirmation_codes

    protected :confirmation_codes

    def initialize(confirmation_codes)
      @confirmation_codes = confirmation_codes
    end

    def get(email)
      unless email.instance_of? Core::ValueObjects::Email
        return Dry::Monads::None()
      end
      
      unless @confirmation_codes[email.value]
        return Dry::Monads::None()
      end

      return Dry::Monads::Some(@confirmation_codes[email.value])
    end
  end
end