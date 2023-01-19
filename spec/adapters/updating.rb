require 'dry-monads'
require 'core/entity'
require 'core/value_objects/email'

module Adapters
  class Updating
    include Dry::Monads[:result]

    attr_reader :confirmation_codes

    protected :confirmation_codes

    def initialize(confirmation_codes)
      @confirmation_codes = confirmation_codes
    end

    def update(confrimation_code)
      unless confrimation_code.instance_of? Core::Entity
        return Dry::Monads::Failure('Invalid code')
      end

      @confirmation_codes[
        confrimation_code.email.value
      ] = confrimation_code

      return Dry::Monads::Success(true)
    end
  end
end