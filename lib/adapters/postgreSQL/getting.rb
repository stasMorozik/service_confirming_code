require 'pg'
require 'dry-monads'
require_relative '../core/entity'
require_relative '../core/value_objects/email'

module Adapters
  module PostgreSQL
    class Getting
      attr_reader :db

      protected :db

      def initialize(db)
        @db = db
      end

      def get(email)
        unless email.instance_of? Core::ValueObjects::Email
          return Dry::Monads::None()
        end
      end
    end
  end
end