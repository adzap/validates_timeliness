# TODO add support switching US to euro date formats
module ValidatesTimeliness
  module Formats
    mattr_accessor :valid_time_formats
    mattr_accessor :valid_date_formats
    mattr_accessor :valid_datetime_formats
    
    mattr_accessor :valid_time_expressions
    mattr_accessor :valid_date_expressions
    mattr_accessor :valid_datetime_expressions
    
    # Format tokens:
    #   
    #      y = year
    #      m = month
    #      d = day
    #      h = hour
    #      n = minute
    #      s = second
    #      u = micro-second
    #   ampm = meridian (am or pm) with or without dots (eg, am, a.m, or a.m.)
    #      _ = optional space
    #
    #   All other characters are considered literal. You can embed regexp in the
    #   format but no gurantees that it will remain intact. If you avoid the use
    #   of any token characters in the regexp it may well work as expected. 
    #
    # Repeating tokens:
    #        
    #   x     = 1 or 2 digits for unit (e.g. 'h' means an hour can be '9' or '09')
    #   xx    = 2 digits exactly for unit (e.g. 'hh' means an hour can only be '09')
    #   yyyyy = exactly 4 digit year
    #   mmm   = month long name (e.g. 'Jul' or 'July')
    #
    #   Any other combination of repeating tokens will be swallowed up by the next
    #   lowest length valid repeating token (e.g. yyy will be replaced with yy)
    
    @@valid_time_formats = [
      'hh:nn:ss',
      'hh-nn-ss',
      'hh:nn',
      'h.nn',
      'h nn',
      'h-nn',
      'h:nn_ampm',
      'h.nn_ampm',
      'h nn_ampm',
      'h-nn_ampm',
      'h_ampm'
    ]
    
    @@valid_date_formats = [
      'yyyy/mm/dd',
      'yyyy-mm-dd',
      'yyyy.mm.dd',
      'm/d/yyyy',
      'd/m/yyyy',
      'd-m-yyyy',
      'd.m.yyyy',
      'm/d/yy',      
      'd/m/yy',
      'd-m-yy',
      'd.m.yy',
      'd mmm yyyy',
      'd mmm yy'
    ]
    
    @@valid_datetime_formats = [
      'yyyy-mm-dd hh:nn:ss',
      'yyyy-mm-dd hh:nn',
      'yyyy-mm-ddThh:nn:ss(?:Z|([-+]\d{2}:\d{2}))'
    ]
     
    def self.format_regexp_generator(string_format)
      regexp = string_format.dup
      order  = {}
      ord = lambda {|k| order[k] = $~.begin(0) }
      regexp.gsub!(/([\.\/])/,         '\\1')      
      regexp.gsub!(/m{3,}/,            '(\w{3,9})') && ord.call(:month)
      regexp.gsub!(/m{2}/,             '(\d{2})')   && ord.call(:month)
      regexp.gsub!(/(?:\A|[^ap])m{1}/, '(\d{1,2})') && ord.call(:month)
      regexp.gsub!(/y{4,}/,            '(\d{4})')   && ord.call(:year)
      regexp.gsub!(/y{2,}/,            '(\d{2})')   && ord.call(:year)
      regexp.gsub!(/h{2,}/,            '(\d{2})')   && ord.call(:hour)
      regexp.gsub!(/h{1}/,             '(\d{1,2})') && ord.call(:hour)
      regexp.gsub!(/n{2,}/,            '(\d{2})')   && ord.call(:min)
      regexp.gsub!(/n{1}/,             '(\d{1,2})') && ord.call(:min)
      regexp.gsub!(/s{2,}/,            '(\d{2})')   && ord.call(:sec)
      regexp.gsub!(/s{1}/,             '(\d{1,2})') && ord.call(:sec)
      regexp.gsub!(/u{1,}/,            '(\d{1,3})') && ord.call(:usec)
      regexp.gsub!(/d{2,}/,            '(\d{2})')   && ord.call(:day)            
      regexp.gsub!(/(?:[^\\]|\A)d{1}/, '(\d{1,2})') && ord.call(:day)
      regexp.gsub!(/ampm/,             '((?:a|p)\.?m\.?)') && ord.call(:meridian)
      regexp.gsub!(/_/,                '\s?')
      format_regexp = Regexp.new(regexp)
      format_proc = format_proc(order)
      return format_regexp, format_proc
    rescue
      puts "The following format regular expression failed to compile: #{regexp}\n from format #{string_format}"
      raise
    end
    
    # Generates a proc which when executed maps the regexp capture groups to a 
    # time array based on the order of the capture groups. 
    #
    # Examples:
    #
    #   'yyyy-mm-dd hh:nn'     => lambda {|y,m,d,h,n| md||=0; [unambiguous_year(y),m,d,full_hour(h,md),n,nil,nil] }
    #   'dd/mm/yyyy h:nn_ampm' => lambda {|d,m,y,h,n,md| md||=0; [unambiguous_year(y),m,d,full_hour(h,md),n,nil,nil] }
    #
    def self.format_proc(order)
      arg_map = {
        :year  => [0, 'y', 'unambiguous_year(y)'],
        :month => [1, 'm', 'm'],
        :day   => [2, 'd', 'd'],
        :hour  => [3, 'h', 'full_hour(h,md)'],
        :min   => [4, 'n', 'n'],
        :sec   => [5, 's', 's'],
        :usec  => [6, 'u', 'u'],
        :meridian => [nil, 'md', nil]
      }
      args = order.invert.sort.map {|p| arg_map[p[1]][1] }
      arr = [nil] * 7
      order.keys.each {|k| i = arg_map[k][0]; arr[i] = arg_map[k][2] unless i.nil? }
      proc_string = "lambda {|#{args.join(',')}| md||=nil; [#{arr.map {|i| i.nil? ? 'nil' : i }.join(',')}] }"
      eval proc_string
    end
    
    def self.compile_formats(formats)
      formats.collect do |format|
        regexp, format_proc = format_regexp_generator(format)
      end
    end
    
    def self.compile_format_expressions
      @@valid_time_expressions = compile_formats(@@valid_time_formats)
      @@valid_date_expressions = compile_formats(@@valid_date_formats)
      @@valid_datetime_expressions = compile_formats(@@valid_datetime_formats)
    end
    
    def self.full_hour(hour, meridian)
      hour = hour.to_i
      return hour if meridian.nil?
      if meridian.delete('.').downcase == 'am'
        hour == 12 ? 0 : hour
      else
        hour == 12 ? hour : hour + 12
      end
    end
    
    def self.unambiguous_year(year, threshold=30)
      year = "#{year.to_i < threshold ? '20' : '19'}#{year}" if year.length == 2
      year.to_i
    end

  end
end
