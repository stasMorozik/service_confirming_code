require 'core/entity'
require 'core/value_objects/email'

describe "Entity" do

  describe "create" do
    context "valid" do
      it 'test@gmail.com' do
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = Core::Entity.create(email)
          expect(result.success?).to eq(true)
        end
      end
    end

    context "invalid" do
      it 'test@.' do
        r = Core::Entity.create('test@.')
        expect(r.failure?).to eq(true)
      end

      it 'test@.' do
        r = Core::ValueObjects::Email.create('test@.')
        expect(r.failure?).to eq(true)
      end
    end
  end

  describe "confirm" do
    context "valid" do
      it 'test@gmail.com' do
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = Core::Entity.create(email)
          result.bind do |confrimation_code|
            result = confrimation_code.confirm(confrimation_code.code)
            expect(result.success?).to eq(true)
          end
        end
      end
    end

    context "invalid" do
      it 'test1@gmail.com' do
        r = Core::ValueObjects::Email.create('test1@gmail.com')
        r.bind do |email|
          result = Core::Entity.create(email)
          result.bind do |confrimation_code|
            result = confrimation_code.confirm(12)
            expect(result.failure?).to eq(true)
          end
        end
      end
    end
  end

  describe "is confirm" do
    context "valid" do
      it 'test@gmail.com' do
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = Core::Entity.create(email)
          result.bind do |confrimation_code|
            confrimation_code.confirm(confrimation_code.code)
            result = confrimation_code.is_confirmed()
            expect(result.success?).to eq(true)
          end
        end
      end
    end

    context "invalid" do
      r = Core::Entity.create('test@gmail.com')
      it 'test@gmail.com' do
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = Core::Entity.create(email)
          result.bind do |confrimation_code|
            result = confrimation_code.is_confirmed()
            expect(result.failure?).to eq(true)
          end
        end
      end
    end
  end

  describe "is alive" do
    context "valid" do
      it 'test@gmail.com' do
        r = Core::ValueObjects::Email.create('test@gmail.com')
        r.bind do |email|
          result = Core::Entity.create(email)
          result.bind do |confrimation_code|
            result = confrimation_code.is_alive()
            expect(result.success?).to eq(true)
          end
        end
      end
    end
  end
end