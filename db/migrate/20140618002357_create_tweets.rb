class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :boltweet_uniq_id
      t.string :tweet_id
      t.string :tweet_user_profile_image_url
      t.text :tweet_content
      t.datetime :tweet_created_at

      t.timestamps
    end
  end
end
