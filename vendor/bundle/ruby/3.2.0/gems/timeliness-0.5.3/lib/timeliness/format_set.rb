# frozen_string_literal: true

module Timeliness
  class FormatSet
    attr_reader :formats, :regexp

    def self.compile(formats)
      new(formats).compile!
    end

    def initialize(formats)
      @formats       = formats
      @formats_hash  = {}
      @match_indexes = {}
    end

    # Compiles the formats into one big regexp. Stores the index of where
    # each format's capture values begin in the matchdata.
    def compile!
      regexp_string = +''
      @formats.inject(0) { |index, format_string|
        format = Format.new(format_string).compile!
        @formats_hash[format_string] = format
        @match_indexes[index] = format
        regexp_string.concat("(?>#{format.regexp_string})|")
        index + format.token_count
      }
      @regexp = %r[\A(?:#{regexp_string.chop})\z]
      self
    end

    def match(string, format_string=nil)
      format = single_format(format_string) if format_string
      match_regexp = format ? format.regexp : @regexp

      if (match_data = match_regexp.match(string))
        captures = match_data.captures # For a multi-format regexp there are lots of nils
        index = captures.index { |e| !e.nil? } # Find the start of captures for matched format
        values = captures[index, 8]
        format ||= @match_indexes[index]
        format.process(*values)
      end
    end

    def single_format(format_string)
      @formats_hash.fetch(format_string) { Format.new(format_string).compile! }
    end
  end
end
