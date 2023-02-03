require 'json'
require 'date'

module Apps
  module Amqp
    class App
      attr_reader :creating_use_case
      attr_reader :confirming_use_case
      attr_reader :channel
      attr_reader :creating_queue
      attr_reader :confirming_queue
      attr_reader :response_queue
      attr_reader :logging_queue
      attr_reader :id_app

      def initialize(
        creating_use_case,
        confirming_use_case,
        channel,
        creating_queue,
        confirming_queue,
        response_queue,
        logging_queue,
        id_app
      )
        @creating_use_case = creating_use_case
        @confirming_use_case = confirming_use_case
        @channel = channel
        @creating_queue = creating_queue
        @confirming_queue = confirming_queue
        @response_queue = response_queue
        @logging_queue = logging_queue
        @id_app = id_app
      end

      def run
        @creating_queue.subscribe(manual_ack: true) do |delivery_info, metadata, payload|
          @channel.ack(delivery_info.delivery_tag)
          begin
            hash = JSON.parse(payload)
            @creating_use_case.create(hash['email']).either(
              -> success {
                @logging_queue.publish("Result of operation creating confirmation code - #{success}. #{@confirming_queue} #{DateTime.now} #{id_app}. Payload - #{payload}")
                @response_queue.publish(JSON.generate({"operation" => "creating", "message" => success, "success" => true}))
              },
              -> failure {
                @logging_queue.publish("Result of operation creating confirmation code - #{failure}. #{@confirming_queue} #{DateTime.now} #{id_app}. Payload - #{payload}")
                @response_queue.publish(JSON.generate({"operation" => "creating", "message" => failure, "success" => false}))
              }
            )
          rescue => e
            @logging_queue.publish("An error of type #{e.class} happened, message is #{e.message}. #{@creating_queue} #{DateTime.now} #{id_app}. Payload - #{payload}")
            @response_queue.publish(JSON.generate({"operation" => "creating", "message" => "Something went wrong", "success" => false}))
          end
        end

        @confirming_queue.subscribe(manual_ack: true) do |delivery_info, metadata, payload|
          @channel.ack(delivery_info.delivery_tag)
          begin
            hash = JSON.parse(payload)
            @confirming_use_case.confirm(hash['email'], hash['code']).either(
              -> success {
                @logging_queue.publish("Result of operation confirming - #{success}. #{@confirming_queue} #{DateTime.now} #{id_app}. Payload - #{payload}")
                @response_queue.publish(JSON.generate({"operation" => "confirming", "message" => success, "success" => true}))
              },
              -> failure {
                @logging_queue.publish("Result of operation confirming - #{failure}. #{@confirming_queue} #{DateTime.now} #{id_app}. Payload - #{payload}")
                @response_queue.publish(JSON.generate({"operation" => "confirming", "message" => failure, "success" => false}))
              }
            )
          rescue => e
            @logging_queue.publish("An error of type #{e.class} happened, message is #{e.message}. #{@confirming_queue} #{DateTime.now} #{id_app}. Payload - #{payload}")
            @response_queue.publish(JSON.generate({"operation" => "confirming", "message" => "Something went wrong", "success" => false}))
          end
        end

        loop do
          sleep 5
        end
      end
    end
  end
end
