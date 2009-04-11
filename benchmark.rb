$:.unshift(File.expand_path('lib'))

require 'date'
require 'parsedate'
require 'benchmark'
require 'rubygems'
require 'active_record'

require 'validates_timeliness'

def parse(*args)
  ValidatesTimeliness::Parser.parse(*args) 
end

n = 10000
Benchmark.bm do |x|
  x.report('timeliness - datetime') { 
    n.times do
      parse("2000-01-04 12:12:12", :datetime)
    end 
  }

  x.report('timeliness - date') { 
    n.times do
      parse("2000-01-04", :date)
    end 
  }
  
  x.report('timeliness - date as datetime') { 
    n.times do
      parse("2000-01-04", :datetime)
    end 
  }

  x.report('timeliness - time') { 
    n.times do
      parse("12:01:02", :time)
    end 
  }
  
  x.report('timeliness - invalid format datetime') { 
    n.times do
      parse("20xx-01-04 12:12:12", :datetime)
    end 
  }

  x.report('timeliness - invalid format date') { 
    n.times do
      parse("20xx-01-04", :date)
    end 
  }

  x.report('timeliness - invalid format time') { 
    n.times do
      parse("12:xx:02", :time)
    end 
  }
  

  x.report('timeliness - invalid value datetime') { 
    n.times do
      parse("2000-01-32 12:12:12", :datetime)
    end 
  }

  x.report('timeliness - invalid value date') { 
    n.times do
      parse("2000-01-32", :date)
    end 
  }

  x.report('timeliness - invalid value time') {
    n.times do
      parse("12:61:02", :time)
    end 
  }
  x.report('date/time') { 
    n.times do
      "2000-01-04 12:12:12" =~ /\A(\d{4})-(\d{2})-(\d{2}) (\d{2})[\. :](\d{2})([\. :](\d{2}))?\Z/
      arr = [$1, $2, $3, $3, $5, $6].map {|i| i.to_i }
      Date.new(*arr[0..2])
      Time.mktime(*arr)
    end
  }
  
  x.report('parsedate') { 
    n.times do
      arr = ParseDate.parsedate("2000-01-04 12:12:12")
      Date.new(*arr[0..2])
      Time.mktime(*arr)
    end 
  }
  
  x.report('strptime') { 
    n.times do
      DateTime.strptime("2000-01-04 12:12:12", '%Y-%m-%d %H:%M:%s')
    end 
  }
end
