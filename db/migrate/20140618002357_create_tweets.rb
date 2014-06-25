class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :tweet_id
      t.text :tweet_content
      t.datetime :tweet_created_at

      t.timestamps
    end
  end
end
