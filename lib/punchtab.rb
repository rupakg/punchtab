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

    # authentication api methods
    def initialize(options = {})
      # initialize the API
      @api = Punchtab::API.new(options)

      # authenticate
      @access_token = @api.authenticate

    end

    def status
      @api.status
    end

    def logout
      @api.logout
    end

    # activity api methods
    def get_activity(options={})
      @api.get_activity(options)
    end

    def create_activity(activity_name, options={})
      @api.create_activity(activity_name, options)
    end

    def redeem_activity_offer(reward_id)
      @api.redeem_activity_offer(reward_id)
    end

    # user api methods
    def get_user
      @api.get_user
    end

    # reward api methods
    def get_reward(options={})
      @api.get_reward(options)
    end

    # leaderboard api methods
    def get_leaderboard(options={})
      @api.get_leaderboard(options)
    end

  end
end

