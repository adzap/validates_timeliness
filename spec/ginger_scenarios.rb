# For use with the ginger gem to test plugin against multiple versions of Rails.
#
# To use ginger:
#
#   gem install ginger
#
# Then run
#
#   ginger spec
#
Ginger.configure do |config|
  rails_versions = ['2.0.2', '2.1.2', '2.2.2', '2.3.3', '2.3.4', '2.3.5']

  rails_versions.each do |v|
    g = Ginger::Scenario.new("Rails #{v}")
    g['rails'] = v
    config.scenarios << g.dup
  end
end
