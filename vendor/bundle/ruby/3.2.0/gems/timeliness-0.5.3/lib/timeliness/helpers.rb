# frozen_string_literal: true

module Timeliness
  module Helpers
    # Helper methods used in format component processing. See Definitions.

    def full_hour(hour, meridian)
      hour = hour.to_i
      return hour if meridian.nil?

      meridian.delete!('.')
      meridian.downcase!

      if meridian == 'am'
        raise(ArgumentError) if hour == 0 || hour > 12
        hour == 12 ? 0 : hour
      else
        hour == 12 ? hour : hour + 12
      end
    end

    def unambiguous_year(year)
      if year.length <= 2
        century = Time.now.year.to_s[0..1].to_i
        century -= 1 if year.to_i >= Timeliness.configuration.ambiguous_year_threshold
        year = "#{century}#{year.rjust(2,'0')}"
      end
      year.to_i
    end

    def month_index(month)
      return month.to_i if month.match?(/\d/)
      (month.length > 3 ? month_names : abbr_month_names).index { |str| month.casecmp?(str) }
    end

    def month_names
      i18n_loaded? ? I18n.t('date.month_names') : Date::MONTHNAMES
    end

    def abbr_month_names
      i18n_loaded? ? I18n.t('date.abbr_month_names') : Date::ABBR_MONTHNAMES
    end

    def microseconds(usec)
      (".#{usec}".to_f * 1_000_000).to_i
    end

    def offset_in_seconds(offset)
      offset =~ /^([-+])?(\d{2}):?(\d{2})/
      ($1 == '-' ? -1 : 1) * ($2.to_f * 3600 + $3.to_f * 60)
    end

    def i18n_loaded?
      defined?(I18n)
    end

  end
end
