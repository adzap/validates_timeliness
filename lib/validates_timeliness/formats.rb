require 'date'

module ValidatesTimeliness
  
  # A date and time format regular expression generator. Allows you to 
  # construct a date, time or datetime format using predefined tokens in 
  # a string. This makes it much easier to catalogue and customize the formats
  # rather than dealing directly with regular expressions. The formats are then
  # compiled into regular expressions for use validating date or time strings. 
  #
  # Formats can be added or removed to customize the set of valid date or time
  # string values.
  #
  class Formats
    cattr_accessor :time_formats,
                   :date_formats,
                   :datetime_formats,
                   :time_expressions,
                   :date_expressions,
                   :datetime_expressions,
                   :format_tokens,
                   :format_proc_args
    

    # Set the threshold value for a two digit year to be considered last century
    #
    # Default: 30
    #
    #   Example:
    #     year = '29' is considered 2029
    #     year = '30' is considered 1930
    # 
    cattr_accessor :ambiguous_year_threshold
    self.ambiguous_year_threshold = 30

    # Set the dummy date part for a time type value. Should be an array of 3 values
    # being year, month and day in that order.
    #
    # Default: [ 2000, 1, 1 ] same as ActiveRecord
    # 
    cattr_accessor :dummy_date_for_time_type
    self.dummy_date_for_time_type = [ 2000, 1, 1 ]

    # Format tokens:   
    #       y = year
    #       m = month
    #       d = day
    #       h = hour
    #       n = minute
    #       s = second
    #       u = micro-seconds
    #    ampm = meridian (am or pm) with or without dots (e.g. am, a.m, or a.m.)
    #       _ = optional space
    #      tz = Timezone abbreviation (e.g. UTC, GMT, PST, EST)
    #      zo = Timezone offset (e.g. +10:00, -08:00, +1000)
    #
    #   All other characters are considered literal. You can embed regexp in the
    #   format but no gurantees that it will remain intact. If you avoid the use
    #   of any token characters and regexp dots or backslashes as special characters 
    #   in the regexp, it may well work as expected. For special characters use 
    #   POSIX character clsses for safety.
    #
    # Repeating tokens:        
    #       x = 1 or 2 digits for unit (e.g. 'h' means an hour can be '9' or '09')
    #      xx = 2 digits exactly for unit (e.g. 'hh' means an hour can only be '09')
    #      
    # Special Cases:
    #      yy = 2 or 4 digit year
    #    yyyy = exactly 4 digit year
    #     mmm = month long name (e.g. 'Jul' or 'July')
    #     ddd = Day name of 3 to 9 letters (e.g. Wed or Wednesday)
    #       u = microseconds matches 1 to 6 digits
    #
    #   Any other invalid combination of repeating tokens will be swallowed up 
    #   by the next lowest length valid repeating token (e.g. yyy will be
    #   replaced with yy)
    
    @@time_formats = [
      'hh:nn:ss',
      'hh-nn-ss',
      'h:nn',
      'h.nn',
      'h nn',
      'h-nn',
      'h:nn_ampm',
      'h.nn_ampm',
      'h nn_ampm',
      'h-nn_ampm',
      'h_ampm'
    ]
    
    @@date_formats = [
      'yyyy-mm-dd',
      'yyyy/mm/dd',
      'yyyy.mm.dd',
      'm/d/yy',
      'd/m/yy',
      'm\d\yy',
      'd\m\yy',
      'd-m-yy',
      'd.m.yy',
      'd mmm yy'
    ]
    
    @@datetime_formats = [
      'yyyy-mm-dd hh:nn:ss',
      'yyyy-mm-dd h:nn',
      'yyyy-mm-dd h:nn_ampm',
      'yyyy-mm-dd hh:nn:ss.u',
      'm/d/yy h:nn:ss',
      'm/d/yy h:nn_ampm',
      'm/d/yy h:nn',
      'd/m/yy hh:nn:ss',
      'd/m/yy h:nn_ampm',
      'd/m/yy h:nn',
      'ddd, dd mmm yyyy hh:nn:ss (zo|tz)', # RFC 822
      'ddd mmm d hh:nn:ss zo yyyy', # Ruby time string
      'yyyy-mm-ddThh:nn:ss(?:Z|zo)' # iso 8601
    ]
    
    
    # All tokens available for format construction. The token array is made of 
    # token regexp, validation regexp and key for format proc mapping if any.
    # If the token needs no format proc arg then the validation regexp should
    # not have a capturing group, as all captured groups are passed to the 
    # format proc.
    #
    # The token regexp should only use a capture group if 'look-behind' anchor
    # is required. The first capture group will be considered a literal and put
    # into the validation regexp string as-is. This is a hack.
    @@format_tokens = [
      { 'd'    => [ /(\A|[^d])d{1}(?=[^d])/, '(\d{1,2})', :day ] }, #/
      { 'ddd'  => [ /d{3,}/, '(\w{3,9})' ] },
      { 'dd'   => [ /d{2,}/, '(\d{2})',   :day ] },
      { 'mmm'  => [ /m{3,}/, '(\w{3,9})', :month ] },
      { 'mm'   => [ /m{2}/,  '(\d{2})',   :month ] },
      { 'm'    => [ /(\A|[^ap])m{1}/, '(\d{1,2})', :month ] },
      { 'yyyy' => [ /y{4,}/, '(\d{4})',   :year ] },
      { 'yy'   => [ /y{2,}/, '(\d{4}|\d{2})', :year ] },
      { 'hh'   => [ /h{2,}/, '(\d{2})',   :hour ] },
      { 'h'    => [ /h{1}/,  '(\d{1,2})', :hour ] },
      { 'nn'   => [ /n{2,}/, '(\d{2})',   :min ]  },
      { 'n'    => [ /n{1}/,  '(\d{1,2})', :min ] },
      { 'ss'   => [ /s{2,}/, '(\d{2})',   :sec ] },
      { 's'    => [ /s{1}/,  '(\d{1,2})', :sec ] },
      { 'u'    => [ /u{1,}/, '(\d{1,6})', :usec ] },
      { 'ampm' => [ /ampm/,  '((?:[aApP])\.?[mM]\.?)', :meridian ] },
      { 'zo'   => [ /zo/,    '([+-]\d{2}:?\d{2})', :offset ] },
      { 'tz'   => [ /tz/,    '(?:[A-Z]{1,4})' ] }, 
      { '_'    => [ /_/,     '\s?' ] }
    ]
    
    # Arguments which will be passed to the format proc if matched in the 
    # time string. The key must be the key from the format tokens. The array 
    # consists of the arry position of the arg, the arg name, and the code to 
    # place in the time array slot. The position can be nil which means the arg
    # won't be placed in the array.
    #
    # The code can be used to manipulate the arg value if required, otherwise 
    # should just be the arg name.
    #
    @@format_proc_args = {
      :year     => [0,   'y', 'unambiguous_year(y)'],
      :month    => [1,   'm', 'month_index(m)'],
      :day      => [2,   'd', 'd'],
      :hour     => [3,   'h', 'full_hour(h,md)'],
      :min      => [4,   'n', 'n'],
      :sec      => [5,   's', 's'],
      :usec     => [6,   'u', 'microseconds(u)'],
      :offset   => [7,   'z', 'offset_in_seconds(z)'],
      :meridian => [nil, 'md', nil]
    }
    
    class << self
    
      def compile_format_expressions
        @@time_expressions     = compile_formats(@@time_formats)
        @@date_expressions     = compile_formats(@@date_formats)
        @@datetime_expressions = compile_formats(@@datetime_formats)
      end
      
      # Loop through format expressions for type and call proc on matches. Allow
      # pre or post match strings to exist if strict is false. Otherwise wrap
      # regexp in start and end anchors.
      # Returns time array if matches a format, nil otherwise.
      def parse(string, type, options={})
        return string unless string.is_a?(String)
        options.reverse_merge!(:strict => true)

        sets = if options[:format]
          options[:strict] = true
          [ send("#{type}_expressions").assoc(options[:format]) ]
        else
          expression_set(type, string)
        end

        matches = nil
        processor = sets.each do |format, regexp, proc|
          full = /\A#{regexp}\Z/ if options[:strict]
          full ||= case type
          when :date     then /\A#{regexp}/
          when :time     then /#{regexp}\Z/
          when :datetime then /\A#{regexp}\Z/
          end
          break(proc) if matches = full.match(string.strip)
        end
        last = options[:include_offset] ? 8 : 7
        if matches
          values = processor.call(*matches[1..last]) 
          values[0..2] = dummy_date_for_time_type if type == :time
          return values
        end
      end   
      
      # Delete formats of specified type. Error raised if format not found.
      def remove_formats(type, *remove_formats)
        remove_formats.each do |format|
          unless self.send("#{type}_formats").delete(format)
            raise "Format #{format} not found in #{type} formats"
          end
        end
        compile_format_expressions
      end
      
      # Adds new formats. Must specify format type and can specify a :before
      # option to nominate which format the new formats should be inserted in 
      # front on to take higher precedence. 
      # Error is raised if format already exists or if :before format is not found.
      def add_formats(type, *add_formats)
        formats = self.send("#{type}_formats")
        options = {}
        options = add_formats.pop if add_formats.last.is_a?(Hash)
        before = options[:before]
        raise "Format for :before option #{format} was not found." if before && !formats.include?(before)
        
        add_formats.each do |format|
          raise "Format #{format} is already included in #{type} formats" if formats.include?(format)

          index = before ? formats.index(before) : -1
          formats.insert(index, format)
        end
        compile_format_expressions
      end

      # Removes formats where the 1 or 2 digit month comes first, to eliminate
      # formats which are ambiguous with the European style of day then month. 
      # The mmm token is ignored as its not ambigous.
      def remove_us_formats
        us_format_regexp = /\Am{1,2}[^m]/
        date_formats.reject! { |format| us_format_regexp =~ format }
        datetime_formats.reject! { |format| us_format_regexp =~ format }
        compile_format_expressions
      end
    
      def full_hour(hour, meridian)
        hour = hour.to_i
        return hour if meridian.nil?
        if meridian.delete('.').downcase == 'am'
          hour == 12 ? 0 : hour
        else
          hour == 12 ? hour : hour + 12
        end
      end

      def unambiguous_year(year)
        if year.length <= 2
          century = Time.now.year.to_s[0..1].to_i
          century -= 1 if year.to_i >= ambiguous_year_threshold
          year = "#{century}#{year.rjust(2,'0')}"
        end
        year.to_i
      end

      def month_index(month)
        return month.to_i if month.to_i.nonzero?
        abbr_month_names.index(month.capitalize) || month_names.index(month.capitalize)
      end

      def month_names
        defined?(I18n) ? I18n.t('date.month_names') : Date::MONTHNAMES
      end

      def abbr_month_names
        defined?(I18n) ? I18n.t('date.abbr_month_names') : Date::ABBR_MONTHNAMES
      end

      def microseconds(usec)
        (".#{usec}".to_f * 1_000_000).to_i
      end

      def offset_in_seconds(offset)
        sign = offset =~ /^-/ ? -1 : 1
        parts = offset.scan(/\d\d/).map {|p| p.to_f }
        parts[1] = parts[1].to_f / 60
        (parts[0] + parts[1]) * sign * 3600
      end

    private
      
      # Compile formats into validation regexps and format procs    
      def format_expression_generator(string_format)
        regexp = string_format.dup      
        order  = {}
        regexp.gsub!(/([\.\\])/, '\\\\\1') # escapes dots and backslashes
        
        format_tokens.each do |token|
          token_name = token.keys.first
          token_regexp, regexp_str, arg_key = *token.values.first
          
          # hack for lack of look-behinds. If has a capture group then is 
          # considered an anchor to put straight back in the regexp string.
          regexp.gsub!(token_regexp) {|m| "#{$1}" + regexp_str }
          order[arg_key] = $~.begin(0) if $~ && !arg_key.nil?
        end

        return Regexp.new(regexp), format_proc(order)
      rescue
        raise "The following format regular expression failed to compile: #{regexp}\n from format #{string_format}."
      end
      
      # Generates a proc which when executed maps the regexp capture groups to a 
      # proc argument based on order captured. A time array is built using the proc
      # argument in the position indicated by the first element of the proc arg
      # array.
      #
      def format_proc(order)
        arg_map = format_proc_args
        args = order.invert.sort.map {|p| arg_map[p[1]][1] }
        arr = [nil] * 7
        order.keys.each {|k| i = arg_map[k][0]; arr[i] = arg_map[k][2] unless i.nil? }
        proc_string = <<-EOL
          lambda {|#{args.join(',')}| 
              md ||= nil
              [#{arr.map {|i| i.nil? ? 'nil' : i }.join(',')}].map {|i| i.is_a?(Float) ? i : i.to_i }
          }
        EOL
        eval proc_string
      end
      
      def compile_formats(formats)
        formats.map { |format| [ format, *format_expression_generator(format) ] }
      end
  
      # Pick expression set and combine date and datetimes for 
      # datetime attributes to allow date string as datetime
      def expression_set(type, string)
        case type
        when :date
          date_expressions
        when :time
          time_expressions
        when :datetime
          # gives a speed-up for date string as datetime attributes
          if string.length < 11
            date_expressions + datetime_expressions
          else
            datetime_expressions + date_expressions
          end
        end
      end
 
    end
  end
end

ValidatesTimeliness::Formats.compile_format_expressions
