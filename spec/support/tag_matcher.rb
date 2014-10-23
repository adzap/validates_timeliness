require 'nokogiri'

module TagMatcher
  extend RSpec::Matchers::DSL

  matcher :have_tag do |selector|
    match do |subject|
      matches = doc(subject).search(selector)

      if @inner_text
        matches = matches.select { |element| element.inner_text == @inner_text }
      end

      matches.any?
    end

    chain :with_inner_text do |inner_text|
      @inner_text = inner_text
    end

    private

    def body(subject)
      if subject.respond_to?(:body)
        subject.body
      else
        subject.to_s
      end
    end

    def doc(subject)
      @doc ||= Nokogiri::HTML(body(subject))
    end
  end
end
