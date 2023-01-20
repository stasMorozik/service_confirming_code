require 'pg'
require 'dry-monads'
require_relative 'mappers/entity'

module Adapters
  module PostgreSQL
    class Getting
      include Dry::Monads[:result]

      attr_reader :connect

      protected :connect

      def initialize(connect)
        @connect = connect
      end

      def get(email)
        unless email.instance_of? Core::ValueObjects::Email
          return Dry::Monads::Failure('Code is not found')
        end

        result = @connect.exec(
          %q{SELECT * FROM codes WHERE email = $1},
          [email.value]
        )

        if result.num_tuples == 0
          return Dry::Monads::Failure('Code is not found')
        end
        
        Dry::Monads::Success(Adapters::PostgreSQL::Mappers::Entity.create(
          result.values[0][0],
          result.values[0][1].to_i,
          result.values[0][2].to_i,
          result.values[0][3] == 't' ? true : false
        ))
      end
    end
  end
end