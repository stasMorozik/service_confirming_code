require 'dry-monads'
require_relative '../entity'
require_relative '../value_objects/email'

module Core
  module UseCases
    class Creating
      include Dry::Monads[:result, :maybe]

      attr_reader :getting_port
      attr_reader :creating_port
      attr_reader :notifying_port

      protected :getting_port
      protected :creating_port
      protected :notifying_port

      def initialize(getting_port, creating_port, notifying_port)
        @getting_port = getting_port
        @creating_port = creating_port
        @notifying_port = notifying_port
      end

      def create(email)
        result_email = Core::ValueObjects::Email.create(email)

        if result_email.failure?
          return result_email
        end

        maybe_entity = result_email.bind do |email|
          @getting_port.get(email)
        end


        result_lifetime = maybe_entity.either(
          -> entity {
            result_is_confirmed = entity.is_confirmed()
            result_is_confirmed.or(entity.lifetime())
          },
          -> error { Dry::Monads::Success("Entity not found") }
        )

        result_created = result_lifetime.either(
          -> success {
            result_email.fmap(-> email {
              result_entity = Core::Entity.create(email)

              result_entity.either(
                -> entity {
                  @creating_port.create(entity).either(
                    -> success {
                      entity
                    },
                    -> error {
                      Dry::Monads::Failure(error)
                    }
                  )
                },
                -> error {
                  Dry::Monads::Failure(error)
                }
              )
            })
          },
          -> error {
            Dry::Monads::Failure(error)
          }
        )

        result_created.either(
          -> entity {
            @notifying_port.notify(entity.email, "Hello! Your Code is #{entity.code}.")
          },
          -> error {
            Dry::Monads::Failure(error)
          }
        )
      end
    end
  end
end
