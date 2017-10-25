# frozen_string_literal: true

module Todoable
  # Class for managing instances of Todoable Todo Lists
  class List
    attr_accessor :id, :name, :items

    def initialize(name:)
      @name = name
    end

    def self.build_from_response(attributes)
      list = new(name: attributes['name'])
      list.id = attributes['id']
      list.items = attributes['items'].map do |item|
        ListItem.build_from_response(item)
      end
      list
    end

    def post_body
      {
        "list": {
          "name": name
        }
      }.to_json
    end

    def persisted
      !id.nil?
    end

    def attributes
      {
        id: @id,
        name: @name,
        items: @items.map(&:attributes)
      }
    end
  end
end
