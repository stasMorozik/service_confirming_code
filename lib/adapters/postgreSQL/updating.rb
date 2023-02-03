require 'pg'
require 'dry-monads'

module Adapters
  module PostgreSQL
    class Updating
      include Dry::Monads[:result]

      attr_reader :connect

      protected :connect

      def initialize(connect)
        @connect = connect
      end

      def update(entity)
        instance_of_mapper_entity = entity.instance_of? Adapters::PostgreSQL::Mappers::Entity
        instance_of_entity = entity.instance_of? Core::Entity

        if instance_of_mapper_entity == false && instance_of_entity == false
          return Dry::Monads::Failure('Invalid entity')
        end

        res = @connect.transaction do |conn|
          conn.exec_params(
            'UPDATE codes SET confirmed = $1 WHERE email = $2',
            [
              entity.confirmed,
              entity.email.value
            ]
          )
        end

        Dry::Monads::Success(true)
      end
    end
  end
end
