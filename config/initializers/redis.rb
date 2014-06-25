$redis = Redis::Namespace.new("boltweet", :redis => Redis.new)

$redis.set("ben","jeff")