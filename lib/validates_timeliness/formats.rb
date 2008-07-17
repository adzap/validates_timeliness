# TODO add support switching US to euro date formats
module ValidatesTimeliness
  module Formats
    mattr_accessor :valid_time_formats
    mattr_accessor :valid_date_formats
    mattr_accessor :valid_datetime_formats

    # The if you want to combine a time regexp with a date regexp then you
    # should not use line begin or end anchors in the expression. Pre and post
    # match strings are still checked for validity, and fail the match if they
    # are not empty.
    #
    # The proc object should return an array with 1-3 elements with values 
    # ordered like so [hour, minute, second]. The proc should have as many
    # arguments as groups in the regexp or you will get an error.
    @@valid_time_formats = {
      :hhnnss_colons   => /(\d{2}):(\d{2}):(\d{2})/,
      :hhnnss_dashes   => /(\d{2})-(\d{2})-(\d{2})/,
      :hhnn_colons     => /(\d{2}):(\d{2})/,
      :hnn_dots        => /(\d{1,2})\.(\d{2})/,
      :hnn_spaces      => /(\d{1,2})\s(\d{2})/,
      :hnn_dashes      => /(\d{1,2})-(\d{2})/,        
      :hnn_ampm_colons => [ /(\d{1,2}):(\d{2})\s?((?:a|p)\.?m\.?)/i,  lambda {|h, n, md| [full_hour(h, md), n, 0] } ],
      :hnn_ampm_dots   => [ /(\d{1,2})\.(\d{2})\s?((?:a|p)\.?m\.?)/i, lambda {|h, n, md| [full_hour(h, md), n, 0] } ],
      :hnn_ampm_spaces => [ /(\d{1,2})\s(\d{2})\s?((?:a|p)\.?m\.?)/i, lambda {|h, n, md| [full_hour(h, md), n, 0] } ],
      :hnn_ampm_dashes => [ /(\d{1,2})-(\d{2})\s?((?:a|p)\.?m\.?)/i,  lambda {|h, n, md| [full_hour(h, md), n, 0] } ],
      :h_ampm          => [ /(\d{1,2})\s?((?:a|p)\.?m\.?)/i,          lambda {|h, md| [full_hour(h, md), 0, 0] } ]
    }
    
    # The proc object should return an array with 3 elements with values 
    # ordered like so year, month, day. The proc should have as many
    # arguments as groups in the regexp or you will get an error.
    @@valid_date_formats = {
      :yyyymmdd_slashes => /(\d{4})\/(\d{2})\/(\d{2})/,
      :yyyymmdd_dashes  => /(\d{4})-(\d{2})-(\d{2})/,
      :yyyymmdd_slashes => /(\d{4})\.(\d{2})\.(\d{2})/,
      :mdyyyy_slashes   => [ /(\d{1,2})\/(\d{1,2})\/(\d{4})/, lambda {|m, d, y| [y, m, d] } ],
      :dmyyyy_slashes   => [ /(\d{1,2})\/(\d{1,2})\/(\d{4})/, lambda {|d, m ,y| [y, m, d] } ],
      :dmyyyy_dashes    => [ /(\d{1,2})-(\d{1,2})-(\d{4})/,   lambda {|d, m ,y| [y, m, d] } ],
      :dmyyyy_dots      => [ /(\d{1,2})\.(\d{1,2})\.(\d{4})/, lambda {|d, m ,y| [y, m, d] } ],
      :mdyy_slashes     => [ /(\d{1,2})\/(\d{1,2})\/(\d{2})/, lambda {|m, d ,y| [unambiguous_year(y), m, d] } ],
      :dmyy_slashes     => [ /(\d{1,2})\/(\d{1,2})\/(\d{2})/, lambda {|d, m ,y| [unambiguous_year(y), m, d] } ],
      :dmyy_dashes      => [ /(\d{1,2})-(\d{1,2})-(\d{2})/,   lambda {|d, m ,y| [unambiguous_year(y), m, d] } ],
      :dmyy_dots        => [ /(\d{1,2})\.(\d{1,2})\.(\d{2})/, lambda {|d, m ,y| [unambiguous_year(y), m, d] } ],
      :d_mmm_yyyy       => [ /(\d{1,2}) (\w{3,9}) (\d{4})/,   lambda {|d, m ,y| [y, m, d] } ],
      :d_mmm_yy         => [ /(\d{1,2}) (\w{3,9}) (\d{2})/,   lambda {|d, m ,y| [unambiguous_year(y), m, d] } ]
    }
    
    @@valid_datetime_formats = {
      :yyyymmdd_dashes_hhnnss_colons => /#{valid_date_formats[:yyyymmdd_dashes]}\s#{valid_time_formats[:hhnnss_colons]}/,
      :yyyymmdd_dashes_hhnn_colons   => /#{valid_date_formats[:yyyymmdd_dashes]}\s#{valid_time_formats[:hhnn_colons]}/,
      :iso8601 => /#{valid_date_formats[:yyyymmdd_dashes]}T#{valid_time_formats[:hhnnss_colons]}(?:Z|[-+](\d{2}):(\d{2}))?/
    }
    
  end
end
