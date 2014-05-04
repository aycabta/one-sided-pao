require 'bundler'
require 'dm-core'
require 'dm-migrations'

class Target
  include DataMapper::Resource
  property :id, Serial
  property :url, String, :length => 256, :required => true
  property :name, String, :length => 256, :required => true
  property :span_seconds, Integer, :required => true
  property :last_attacked_at, DateTime

  @@seconds_of_day = 60 * 60 * 24
  @@seconds_of_hour = 60 * 60
  @@seconds_of_minute = 60

  def span=(new_span)
    if new_span.kind_of? Numeric
      @span_seconds = new_span
    else new_span.kind_of? String
      @span_seconds = new_span.split(/(?<!\d)/).inject(0) { |result, part|
        result + case part
        when /^(\d+)d$/
          $1.to_i * @@seconds_of_day
        when /^(\d+)h$/
          $1.to_i * @@seconds_of_hour
        when /^(\d+)m$/
          $1.to_i * @@seconds_of_minute
        when /^(\d+)(?:s$|$)/
          $1.to_i
        else
          0
        end
      }
    end
  end

  def span
    rest = @span_seconds
    span_strs = []
    day = (rest / @@seconds_of_day).floor
    if day > 0
      span_strs << (day > 1 ? "#{day} days" : 'a day')
    end
    rest -= day * @@seconds_of_day
    hour = (rest / @@seconds_of_hour).floor
    if hour > 0
      span_strs << (hour > 1 ? "#{hour} hours" : 'a hour')
    end
    rest -= hour * @@seconds_of_hour
    minute = (rest / @@seconds_of_minute).floor
    if minute > 0
      span_strs << (minute > 1 ? "#{minute} minutes" : 'a minute')
    end
    rest -= minute * @@seconds_of_minute
    if rest > 0
      span_strs << (rest > 1 ? "#{rest} seconds" : 'a second')
    end
    span_strs.join(' ')
  end
end

DataMapper.finalize

def database_upgrade!
  Target.auto_upgrade!
end

