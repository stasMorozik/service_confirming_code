require 'adapters/postgreSQL/creating'
require 'core/value_objects/email'
require 'core/entity'
require 'pg'
require 'dotenv/load'

describe "PostgreSQL adapters" do
  describe "creating" do

    Dotenv.load('.env.test')

    connect = PG.connect(
      :dbname   => ENV["PG_NAME"],
      :host     => ENV["PG_HOST"],
      :port     => ENV["PG_PORT"],
      :user     => ENV["PG_USER"],
      :password => ENV["PG_PASSWORD"]
    )

    creating_adapter = Adapters::PostgreSQL::Creating.new(connect)
    connect.exec("DELETE FROM codes")

    context "valid" do
      it 'test@gmail.com' do
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = Core::Entity.create(email)
          result.bind do |entity|
            result = creating_adapter.create(entity)
            expect(result.success?).to eq(true)
            connect.exec("DELETE FROM codes")
          end
        end
      end
    end
  end
end

