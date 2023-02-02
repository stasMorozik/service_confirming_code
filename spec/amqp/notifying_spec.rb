require 'bunny'
require 'core/value_objects/email'
require 'adapters/amqp/notifying'
require 'dotenv/load'

describe "Amqp adapters" do
  describe "notify" do

    Dotenv.load('.env.test')

    conn = Bunny.new(
      :host => ENV["RB_HOST"],
      :vhost => ENV["RB_VHOST"],
      :user => ENV["RB_USER"],
      :password => ENV["RB_PASSWORD"]
    )

    conn.start

    ch = conn.create_channel
    ch.confirm_select
    queue = ch.queue("test_queue")

    notifying_adapter = Adapters::Amqp::Notifying.new(queue)

    context "valid" do
      it 'test@gmail.com' do
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = notifying_adapter.notify(email, "test")
          expect(result.success?).to eq(true)
          conn.close
        end
      end
    end
  end
end
