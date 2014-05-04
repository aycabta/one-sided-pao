require './model'
require 'eventmachine'
require 'net/http'
require 'uri'

def attack(target)
  begin
    uri = URI(target.url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      http.open_timeout = 2
      http.read_timeout = 2
      http.head(uri.path + uri.query.nil? ? '' : "?#{uri.query}")
    end
  rescue Exception
  end
end

EM::defer do
  loop do
    sleep 3
    Target.all.each do |target|
      if target.last_attacked_at.nil?
        attack(target)
        target.last_attacked_at = DateTime.now
        target.save!
      elsif DateTime.now > (target.last_attacked_at.to_time + target.span_seconds).to_datetime
        attack(target)
        target.last_attacked_at = (target.last_attacked_at.to_time + target.span_seconds).to_datetime
        target.save!
      end
    end
  end
end

