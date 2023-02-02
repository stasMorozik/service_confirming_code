require 'adapters/postgreSQL/getting'
require 'core/value_objects/email'
require 'pg'
require 'dotenv/load'

describe "PostgreSQL adapters" do
  describe "getting" do

    Dotenv.load('.env.test')

    connect = PG.connect(
      :dbname   => ENV["PG_NAME"],
      :host     => ENV["PG_HOST"],
      :port     => ENV["PG_PORT"],
      :user     => ENV["PG_USER"],
      :password => ENV["PG_PASSWORD"]
    )

    getting_adapter = Adapters::PostgreSQL::Getting.new(connect)
    connect.exec("DELETE FROM codes")

    context "valid" do
      it 'test@gmail.com' do
        connect.exec("INSERT INTO codes VALUES( 'test@gmail.com', 1234, 1674213380, false )")
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = getting_adapter.get(email)
          expect(result.success?).to eq(true)
        end
        connect.exec("DELETE FROM codes")
      end
    end

    context "invalid" do
      it 'test@gmail.com' do
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = getting_adapter.get(email)
          expect(result.failure?).to eq(true)
        end
      end
    end
  end
end
