#!/usr/bin/env ruby

# You might want to change this
#ENV["RAILS_ENV"] ||= "production"
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # Replace this with your code
  #Rails.logger.auto_flushing = true
  #Rails.logger.info "This daemon is still running at #{Time.now}.\n"
  
  stream = TweetStream::Client.new

  # Reset some redis keys when starting the daemon
  $redis.flushall # Clear redis completely
  $redis.set("last_time", Time.now - 666.minutes) # Set the time to something
  #$redis.del('winners') # Delete all winners in Redis

  #stream.track('#boltweet') do |status|
  stream.sample do |status|

    boltweet_uniq_id = SecureRandom.hex(4) # Our unique identifier for each tweet

    # Write to the sql database
    @tweet = Tweet.new(
      :boltweet_uniq_id => boltweet_uniq_id,
      :tweet_id => "#{status.user.id}", 
      :tweet_user_profile_image_url => "#{status.user.profile_image_url}", 
      :tweet_content => "#{status.text}", 
      :tweet_created_at => "#{status.created_at}"
    )
    @tweet.save

    # Write to redis
    if $redis.get("last_time") <= Time.now - 1.minutes
      $redis.set("last_time", "#{status.created_at}")
      $redis.hmset(boltweet_uniq_id, 
                  'tweet_user_name', "#{status.user.name}",
                  'tweet_user_image', "#{status.user.profile_image_url}", 
                  'tweet_content', "#{status.text}",
                  'last_time', "#{status.created_at}")
      $redis.lpush('winners', boltweet_uniq_id)

      # Check if there are more than 5 winners in redis
      if $redis.llen('winners') > 5
        $redis.rpop('winners') # Remove oldest winner in redis
      end

    end

  end

end
