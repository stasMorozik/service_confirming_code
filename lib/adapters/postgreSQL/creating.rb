require 'pg'
require 'dry-monads'

module Adapters
  module PostgreSQL
    class Creating
      include Dry::Monads[:result]

      attr_reader :connect

      protected :connect

      def initialize(connect)
        @connect = connect
      end

      def create(entity)
        unless entity.instance_of? Core::Entity
          return Dry::Monads::Failure('Invalid entity')
        end

        @connect.transaction do |conn|
          conn.exec_params('DELETE from codes where email = $1', [entity.email.value])
          conn.exec_params(
            'INSERT INTO codes VALUES($1, $2, $3, $4)', 
            [
              entity.email.value, 
              entity.code, 
              entity.created, 
              entity.confirmed
            ]
          )
        end

        Dry::Monads::Success(true)
      end
    end
  end
end