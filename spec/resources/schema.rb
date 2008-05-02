ActiveRecord::Schema.define(:version => 1) do

  create_table "people", :force => true do |t|    
    t.string   "name"
    t.datetime "birth_date_and_time"
    t.date "birth_date"
  end
  
end
