# For use with the ginger gem to test plugin against multiple versions of Rails.
#
# To use ginger:
#    
#    sudo gem install freelancing-god-ginger --source=http://gems.github.com
#
# Then run
#
#   ginger spec
#
Ginger.configure do |config|
  rails_versions = ['2.0.2', '2.1.2', '2.2.2', '2.3.3', '2.3.4']

  rails_versions.each do |v|
    g = Ginger::Scenario.new("Rails #{v}")
    g['rails'] = v
    config.scenarios << g.dup
  end
end
