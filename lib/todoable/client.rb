require 'HTTParty'
module Todoable
  class Client
    include HTTParty
    base_uri 'https://todoable.teachable.tech/api'

    attr_accessor :token
    attr_writer :username, :password, :options

    # TODO: document this
    def initialize(username: , password: )
      @username, @password = username, password
      @options = {}
    end

    # TODO: document this
    def authenticate
      @options.merge!(
        {
          basic_auth: {
            username: @username,
            password: @password
          }
        }
      )
      response = self.class.post('/authenticate', @options)

      case response.code.to_i
      when 200..300
        @token = response.parsed_response["token"]
        return true
      else
        raise AuthenticationError, "Could not retrive token"
      end
    end

    # TODO: document this
    def self.build(username: , password: )
      new(username: username, password: password).authenticate
    end
  end

  class AuthenticationError < StandardError
  end


end
