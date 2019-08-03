require 'validates_timeliness/railtie'

RSpec.describe ValidatesTimeliness::Railtie do
  context "intializers" do
    context "validates_timeliness.initialize_timeliness_ambiguous_date_format" do
      it 'should set the timeliness default ambiguous date format from the current format' do
        expect(Timeliness.configuration.ambiguous_date_format).to eq :us
        ValidatesTimeliness.parser.use_euro_formats

        initializer("validates_timeliness.initialize_timeliness_ambiguous_date_format").run

        expect(Timeliness.configuration.ambiguous_date_format).to eq :euro
      end
    end if Timeliness.respond_to?(:ambiguous_date_format)

    def initializer(name)
      ValidatesTimeliness::Railtie.initializers.find { |i|
        i.name == name
      } || raise("Initializer #{name} not found")
    end
  end
end
