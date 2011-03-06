# require 'tweetstream/client'
# require 'tweetstream/hash'
# require 'tweetstream/status'
# require 'tweetstream/user'
# require 'tweetstream/daemon'

require File.dirname(__FILE__)+'/tweetstream/client'
require File.dirname(__FILE__)+'/tweetstream/hash'
require File.dirname(__FILE__)+'/tweetstream/status'
require File.dirname(__FILE__)+'/tweetstream/user'
require File.dirname(__FILE__)+'/tweetstream/daemon'

module TweetStream
  class Terminated < ::StandardError; end
  class Error < ::StandardError; end
  class ConnectionError < TweetStream::Error; end
  # A ReconnectError is raised when the maximum number of retries has
  # failed to re-establish a connection.
  class ReconnectError < StandardError
    attr_accessor :timeout, :retries
    def initialize(timeout, retries)
      self.timeout = timeout
      self.retries = retries
      super("Failed to reconnect after #{retries} tries.")
    end
  end
end