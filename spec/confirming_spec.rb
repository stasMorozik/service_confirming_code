require 'core/use_cases/confirming'
require 'core/use_cases/creating'

require 'adapters/getting'
require 'adapters/updating'
require 'adapters/creating'
require 'adapters/notifying'

describe "Use Case" do
  describe "confirm" do
    confrimation_codes = Hash.new
    getting_adapter = Adapters::Gettign.new(confrimation_codes)
    creating_adapter = Adapters::Creating.new(confrimation_codes)
    updating_adapter = Adapters::Updating.new(confrimation_codes)
    notifying_adapter = Adapters::Notifying.new()

    creating_use_case = Core::UseCases::Creating.new(
      getting_adapter,
      creating_adapter,
      notifying_adapter
    )

    confirming_use_case = Core::UseCases::Confirming.new(
      getting_adapter,
      updating_adapter
    )
    
    context "valid" do
      it 'test@gmail.com' do
        creating_use_case.create('test@gmail.com')
        result = confirming_use_case.confirm(
          'test@gmail.com', 
          confrimation_codes['test@gmail.com'].code
        )
        expect(result.success?).to eq(true)
      end
    end

    context "invalid" do
      it 'test1@gmail.com' do
        creating_use_case.create('test1@gmail.com')
        result = confirming_use_case.confirm(
          'test1@gmail.com', 
          12
        )
        expect(result.failure?).to eq(true)
      end

      it 'test2@gmail.com' do
        creating_use_case.create('test2@gmail.com')
        result = confirming_use_case.confirm(
          'tes@gmail.com', 
          12
        )
        expect(result.failure?).to eq(true)
      end
    end
  end
end