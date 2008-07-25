require 'time_travel/time_extensions'

Time.send(:include, TimeTravel::TimeExtensions)

def at_time(time)
  Time.now = time
  begin
    yield
  ensure
    Time.now = nil
  end
end
