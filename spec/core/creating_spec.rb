require 'core/use_cases/creating'

require 'adapters/getting'
require 'adapters/creating'
require 'adapters/notifying'

describe "Use Case" do
  describe "create" do
    confrimation_codes = Hash.new
    getting_adapter = Adapters::Gettign.new(confrimation_codes)
    creating_adapter = Adapters::Creating.new(confrimation_codes)
    notifying_adapter = Adapters::Notifying.new()

    use_case = Core::UseCases::Creating.new(
      getting_adapter,
      creating_adapter,
      notifying_adapter
    )
    
    context "valid" do
      it 'test@gmail.com' do
        result = use_case.create('test@gmail.com')
        expect(result.success?).to eq(true)
      end
    end

    context "invalid" do
      it 'test@' do
        result = use_case.create('test@')
        expect(result.failure?).to eq(true)
      end
    end

    context "already exists" do
      it 'test1@gmail.com' do
        use_case.create('test1@gmail.com')
        result = use_case.create('test1@gmail.com')
        expect(result.failure?).to eq(true)
      end
    end
  end
end