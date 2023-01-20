require 'pg'
require 'bunny'
require 'core/value_objects/email'
require 'adapters/amqp/notifying'

describe "Amqp adapters" do
  describe "notify" do
    conn = Bunny.new(
      :host => "localhost", 
      :vhost => "/",
      :user => "rabbit_user", 
      :password => "12345"
    )
    conn.start

    ch = conn.create_channel
    ch.confirm_select
    queue  = ch.queue("test1")

    notifying_adapter = Adapters::Amqp::Notifying.new(queue)

    context "valid" do
      it 'test@gmail.com' do
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = notifying_adapter.notify(email, "test")
          expect(result.success?).to eq(true)
        end
      end
    end
  end
end