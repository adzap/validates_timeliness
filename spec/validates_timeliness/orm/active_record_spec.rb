RSpec.describe ValidatesTimeliness, 'ActiveRecord' do
  context "validation methods" do
    let(:record) { Employee.new }

    it 'should be defined for the class' do
      expect(ActiveRecord::Base).to respond_to(:validates_date)
      expect(ActiveRecord::Base).to respond_to(:validates_time)
      expect(ActiveRecord::Base).to respond_to(:validates_datetime)
    end

    it 'should defines for the instance' do
      expect(record).to respond_to(:validates_date)
      expect(record).to respond_to(:validates_time)
      expect(record).to respond_to(:validates_datetime)
    end

    it "should validate a valid value string" do
      record.birth_date = '2012-01-01'

      record.valid?
      expect(record.errors[:birth_date]).to be_empty
    end

    it "should validate a invalid value string" do
      record.birth_date = 'not a date'

      record.valid?
      expect(record.birth_date_before_type_cast).to eq 'not a date'
      expect(record.errors[:birth_date]).not_to be_empty
    end

    it "should validate a nil value" do
      record.birth_date = nil

      record.valid?
      expect(record.errors[:birth_date]).to be_empty
    end
  end

  context 'attribute timezone awareness' do
    let(:klass) {
      Class.new(ActiveRecord::Base) do
        self.table_name = 'employees'
        attr_accessor :some_date
        attr_accessor :some_time
        attr_accessor :some_datetime
        validates_date :some_date
        validates_time :some_time
        validates_datetime :some_datetime
      end
    }
  end
  
  context "attribute write method" do
    class EmployeeWithCache < ActiveRecord::Base
      self.table_name = 'employees'
      validates_date :birth_date, :allow_blank => true
      validates_time :birth_time, :allow_blank => true
      validates_datetime :birth_datetime, :allow_blank => true
    end

    context "with plugin parser" do
      with_config(:use_plugin_parser, true)
      let(:record) { EmployeeWithParser.new }

      class EmployeeWithParser < ActiveRecord::Base
        self.table_name = 'employees'
        validates_date :birth_date, :allow_blank => true
        validates_time :birth_time, :allow_blank => true
        validates_datetime :birth_datetime, :allow_blank => true
      end

      before do
        allow(Timeliness::Parser).to receive(:parse).and_call_original
      end

      context "for a date column" do
        it 'should parse a string value' do
          record.birth_date = '2010-01-01'
          expect(record.birth_date).to eq(Date.new(2010, 1, 1))

          expect(Timeliness::Parser).to have_received(:parse)
        end

        it 'should parse a invalid string value as nil' do
          record.birth_date = 'not valid'
          expect(record.birth_date).to be_nil

          expect(Timeliness::Parser).to have_received(:parse)
        end

        it 'should store a Date value after parsing string' do
          record.birth_date = '2010-01-01'

          expect(record.birth_date).to be_kind_of(Date)
          expect(record.birth_date).to eq Date.new(2010, 1, 1)
        end
      end

      context "for a time column" do
        around do |example|
          time_zone_aware_types = ActiveRecord::Base.time_zone_aware_types.dup
          example.call
          ActiveRecord::Base.time_zone_aware_types = time_zone_aware_types
        end

        context 'timezone aware' do
          with_config(:default_timezone, 'Australia/Melbourne')

          before do
            unless ActiveRecord::Base.time_zone_aware_types.include?(:time)
              ActiveRecord::Base.time_zone_aware_types.push(:time)
            end
          end

          it 'should parse a string value' do
            record.birth_time = '12:30'

            expect(record.birth_time).to eq('12:30'.in_time_zone)
            expect(Timeliness::Parser).to have_received(:parse)
          end

          it 'should parse a invalid string value as nil' do
            record.birth_time = 'not valid'

            expect(record.birth_time).to be_nil
            expect(Timeliness::Parser).to have_received(:parse)
          end

          it 'should store a Time value after parsing string' do
            record.birth_time = '12:30'

            expect(record.birth_time).to eq('12:30'.in_time_zone)
            expect(record.birth_time.utc_offset).to eq '12:30'.in_time_zone.utc_offset
          end
        end

        skip 'not timezone aware' do
          before do
            ActiveRecord::Base.time_zone_aware_types.delete(:time)
          end

          it 'should parse a string value' do
            record.birth_time = '12:30'

            expect(record.birth_time).to eq(Time.utc(2000,1,1,12,30))
            expect(Timeliness::Parser).to have_received(:parse)
          end

          it 'should parse a invalid string value as nil' do
            record.birth_time = 'not valid'

            expect(record.birth_time).to be_nil
            expect(Timeliness::Parser).to have_received(:parse)
          end

          it 'should store a Time value in utc' do
            record.birth_time = '12:30'

            expect(record.birth_time.utc_offset).to eq Time.now.utc.utc_offset
          end
        end
      end

      context "for a datetime column" do
        with_config(:default_timezone, 'Australia/Melbourne')

        it 'should parse a string value into Time value' do
          record.birth_datetime = '2010-01-01 12:00'

          expect(record.birth_datetime).to eq Time.zone.local(2010,1,1,12,00)
          expect(Timeliness::Parser).to have_received(:parse)
        end

        it 'should parse a invalid string value as nil' do
          record.birth_datetime = 'not valid'

          expect(record.birth_datetime).to be_nil
          expect(Timeliness::Parser).to have_received(:parse)
        end

        it 'should parse string as current timezone' do
          record.birth_datetime = '2010-06-01 12:00'

          expect(record.birth_datetime.utc_offset).to eq Time.zone.utc_offset
        end
      end
    end
  end
end
