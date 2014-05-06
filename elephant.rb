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
      path = uri.path
      if (not uri.query.nil?) and uri.query.kind_of? String
        path += uri.query
      end
      case target.request_method.to_sym
      when :get
        http.get(path)
      when :post
        http.post(path)
      when :head
        http.head(path)
      end
    end
  rescue Exception => e
    puts "#{e.class.name}: #{e.message}"
    e.backtrace.each do |b|
      puts "\t from #{b}"
    end
  end
end

EM::defer do
  loop do
    sleep 30
    Target.all.each do |target|
      if target.last_attacked_at.nil?
        puts "first attack: #{target.id} \"#{target.name}\" #{target.url}"
        attack(target)
        target.last_attacked_at = DateTime.now
        target.save!
      elsif DateTime.now > (target.last_attacked_at.to_time + target.span_seconds).to_datetime
        puts "#{target.id} \"#{target.name}\" #{target.url}"
        attack(target)
        target.last_attacked_at = (target.last_attacked_at.to_time + target.span_seconds).to_datetime
        target.save!
      end
    end
  end
end

