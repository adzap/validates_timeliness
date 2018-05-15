module ValidatesTimeliness
  module Extensions
    module TimelinessDateTimeSelect
      # Intercepts the date and time select helpers to reuse the values from
      # the params rather than the parsed value. This allows invalid date/time
      # values to be redisplayed instead of blanks to aid correction by the user.
      # It's a minor usability improvement which is rarely an issue for the user.
      attr_accessor :object_name, :method_name, :template_object, :options, :html_options

      POSITION = {
        :year => 1, :month => 2, :day => 3, :hour => 4, :min => 5, :sec => 6
      }.freeze

      def initialize(object_name, method_name, template_object, options, html_options)
        @object_name, @method_name = object_name.to_s.dup, method_name.to_s.dup
        @template_object, @options, @html_options = template_object, options, html_options
      end

      if Rails.version.to_f < 5.2
        def value(object)
          return super(object) unless @template_object.params[@object_name]

          pairs = @template_object.params[@object_name].select {|k,v| k =~ /^#{@method_name}\(/ }
          return super(object) if pairs.empty?

          values = {}
          pairs.each_pair do |key, value|
            position = key[/\((\d+)\w+\)/, 1]
            values[POSITION.key(position.to_i)] = value.to_i
          end

          values
        end
      else
        def value
          return super unless @template_object.params[@object_name]

          pairs = @template_object.params[@object_name].select {|k,v| k =~ /^#{@method_name}\(/ }
          return super if pairs.empty?

          values = {}
          pairs.each_pair do |key, value|
            position = key[/\((\d+)\w+\)/, 1]
            values[POSITION.key(position.to_i)] = value.to_i
          end

          values
        end
      end
    end
  end
end
