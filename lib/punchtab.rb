$:.push File.expand_path('../lib', __FILE__)

require 'rubygems'
require 'hashie'

require 'punchtab/version'
require 'punchtab/utils'
require 'punchtab/api'

module Punchtab

  class Client

    attr_reader :access_token

    def self.version
      Punchtab::VERSION
    end

    # authentication methods
    def initialize(options = {})
      # initialize the API
      @api = Punchtab::API.new(options)

      # authenticate
      response = @api.authenticate
      if response
        # get the access token
        @access_token = @api.access_token
      end

    end

    def status
      @api.status
    end

    def logout
      @api.logout
    end

    # activity methods
    def get_activity(options={})
      @api.get_activity(options)
    end

    def create_activity(activity_name, options={})
      @api.create_activity(activity_name, options)
    end

    def redeem_activity_offer(reward_id)
      @api.redeem_activity_offer(reward_id)
    end


  end
end

