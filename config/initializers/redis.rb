
# Use our redis configuration files
redis_conf = File.read(Rails.root.join("config/redis", "#{Rails.env}.conf"))
$redis = Redis::Namespace.new("boltweet", :redis => Redis.new)