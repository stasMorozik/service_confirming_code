require 'adapters/postgreSQL/creating'
require 'core/value_objects/email'
require 'core/entity'
require 'pg'

describe "PostgreSQL adapters" do
  describe "creating" do
    
    connect = PG.connect(
      :dbname   => 'confirmation_codes',
      :host     => 'localhost',
      :port     => 5432,
      :user     => 'db_user',
      :password => '12345'
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