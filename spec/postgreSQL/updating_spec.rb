require 'adapters/postgreSQL/updating'
require 'core/value_objects/email'
require 'core/entity'
require 'pg'

describe "PostgreSQL adapters" do
  describe "updating" do
    
    connect = PG.connect(
      :dbname   => 'confirmation_codes',
      :host     => 'localhost',
      :port     => 5432,
      :user     => 'db_user',
      :password => '12345'
    )

    updating_adapter = Adapters::PostgreSQL::Updating.new(connect)
    connect.exec("DELETE FROM codes")
    connect.exec("INSERT INTO codes VALUES( 'test@gmail.com', 1234, 1674213380, false )")

    context "valid" do
      it 'test@gmail.com' do
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = Core::Entity.create(email)
          result.bind do |entity|
            result = updating_adapter.update(entity)
            expect(result.success?).to eq(true)
            connect.exec("delete from codes")
          end
        end
      end
    end
  end
end