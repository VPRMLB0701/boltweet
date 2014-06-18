require 'reloader/sse'

class SiteController < ApplicationController
	include ActionController::Live

  # index page has javascript that will query this page to stream it
  def index_stream

    # SSE expects the `text/event-stream` content type
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Reloader::SSE.new(response.stream)
    begin
      
      # Stream the time to the client
      #loop do
      #  sse.write({ :output => Time.now }, :event => 'refresh')
      #end

      # I commented out the twitter streaming below because it's not working correctly
      # It's opening up too many connections at once which it shouldn't do
      # It should be running in a background daemon instead of the clients request

      # Stream random tweets to client
      TweetStream::Client.new.sample do |tweet, client|
        sse.write({ :output => tweet.text }, :event => 'refresh')
        sleep 5
      end

    rescue IOError
      # When the client disconnects, we'll get an IOError on write
    ensure
      client.stop
      sse.close
    end
  end

  def index
  end

  def daemon_test

    @tweets = Tweet.all

    #@user = Site.update(random: "Jeff")
    #@users = Site.all

    #site = Site.find_by(random: 'Jeff')
    #@exist = 

    #user.update(name: 'Dave')

  end

end
