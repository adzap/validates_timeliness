ActiveRecord::Schema.define(:version => 1) do

  create_table "people", :force => true do |t|    
    t.column "name", :string
    t.column "birth_date_and_time", :datetime
    t.column "birth_date", :date
    t.column "birth_time", :time
  end
  
end
