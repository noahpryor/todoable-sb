require 'HTTParty'
module Todoable
  class Client
    include HTTParty
    format :json
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
        return self
      else
        raise AuthenticationError, "Could not retrive token"
      end
    end

    # TODO: document this
    def self.build(username: , password: )
      new(username: username, password: password).authenticate
    end

    def create_list(name: )
      body = { list: { name: name } }.to_json
      response = self.class.post('/lists', body: body, headers: headers)
      case response.code.to_i
      when 200...300
        id = response.headers['Location'].split("/").last
        # TODO: I'm not seeing a location header on list creation
        List.new(id: id, name: name, items: [])
      when 300...400
      when 400...500
        raise UnauthorizedError
      else
        raise StandardError, "Could not create list"
      end
    end

    def lists
      response = self.class.get('/lists', {headers: headers})
      case response.code.to_i
      when 200...300
        response.parsed_response["lists"].map do |json|
          id = json["src"].split("/").last # HACK
          List.new(id: id, name: json['name'], items: [])
        end
      when 400...500
        raise UnauthorizedError
      else
        # TODO: actually handle errors
        raise StandardError, "Could not retrive lists"
      end
    end

    def find_list(id)
      response = self.class.get("/lists/#{id}", {headers: headers})
      case response.code.to_i
      when 200...300
        attributes = response.parsed_response["list"]
        items = []
        attributes["items"].map do |item_json|
          item_id = item_json["src"].split("/").last # HACK
          items << ListItem.build_from_response(
            id: item_id,
            list_id: id,
            name: item_json["name"],
            status: item_json['finished_at'].nil? ? :todo : :done
          )
        end

        List.new(id: id, name: attributes["name"], items: items)

      when 400...500
        raise UnauthorizedError
      else
        # TODO: actually handle errors
        raise StandardError, "Could not retrive lists"
      end
    end

    def update_list(id: , name:)
      body = { list: { name: name } }.to_json
      response = self.class.patch("/lists/#{id}", body: body, headers: headers)
      case response.code.to_i
      when 200...300
        id = response.headers['Location'].split("/").last
        # TODO: I'm not seeing a location header on list response
        List.new(id: id, name: name, items: [])
      when 300...400
      when 400...500
        raise UnauthorizedError
      else
        raise StandardError, "Could not create list"
      end
    end

    def headers
      {'Authorization': "Token token=#{@token}"}
    end

  end

  class AuthenticationError < StandardError
  end

  class UnauthorizedError < StandardError
  end
end
