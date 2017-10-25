# frozen_string_literal: true

require 'httparty'

module Todoable
  # Base class for calling Todoable API
  class Client
    include Api::List
    include Api::ListItem
    include HTTParty
    format :json
    base_uri 'https://todoable.teachable.tech/api'

    attr_accessor :token
    attr_writer :username, :password, :options

    # TODO: document this
    def initialize(username:, password:)
      @username = username
      @password = password
      @options = {}
    end

    # TODO: document this
    def authenticate
      @options[:basic_auth] = {
        username: @username,
        password: @password
      }
      response = self.class.post('/authenticate', @options)
      check_and_raise_errors(response)
      @token = response.parsed_response['token']
      self
    end

    # TODO: document this
    def self.build(username:, password:)
      new(username: username, password: password).authenticate
    end

    private

    def check_token
      return true if @token
      raise NotAuthenticated
    end

    def check_and_raise_errors(response)
      case response.code.to_i
      when 404
        raise ContentNotFoundError
      when 400...500
        raise UnauthorizedError
      when 500
        puts response
      end
    end

    def headers
      { 'Authorization': "Token token=#{@token}" }
    end
  end

  class ContentNotFoundError < StandardError
  end

  class NotAuthenticated < StandardError
  end

  class AuthenticationError < StandardError
  end

  class UnauthorizedError < StandardError
  end
end
