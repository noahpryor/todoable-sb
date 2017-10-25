# frozen_string_literal: true

require 'httparty'

module Todoable
  # Base class for calling Todoable API
  # @attr [String] token The authentication token Todoable returned
  #   in exchange for username and password. Used to authenticate all
  #   requests.
  class Client
    include Api::List
    include Api::ListItem
    include HTTParty
    format :json
    base_uri 'https://todoable.teachable.tech/api'

    attr_reader :token

    # Create a client with a username and password
    #
    # @param username [String] the username from Todoable
    # @param password [String] the password from Todoable
    # @return [Todoable::Client] An unauthenticated client
    #
    # @example
    #   Todoable::Client.new(username: "foo", password: "bar") =>
    #     <Todoable::Client
    #       @token=nil,
    #       @options={},
    #       @username="foo"
    #       @password="bar"
    #     >
    def initialize(username:, password:)
      @username = username
      @password = password
      @options = {}
    end

    # Authenticate an initialized client by making a call to exchange the
    # username and password for a token. Sets the token for future calls from
    # the client
    #
    # @return [Todoable::Client] an authenticated client
    #
    # @example
    #
    #   client = Todoable::Client.new(username: "foo", password: "bar")
    #   client.authenticate =>
    #     <Todoable::Client @token="a-valid-token">

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

    # Convenience initializer to create an authenticated client
    # username and password for a token. Sets the token for future calls from
    # the client
    #
    # @param username [String] the username from Todoable
    # @param password [String] the password from Todoable
    #
    # @return [Todoable::Client] An unauthenticated client
    #
    #
    # @example
    #   client = Todoable::Client.build(username: "foo", password: "bar") =>
    #     <Todoable::Client @token="a-valid-token">

    def self.build(username:, password:)
      new(username: username, password: password).authenticate
    end

    private

    attr_writer :username, :password, :options

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
end
