# frozen_string_literal: true

module Todoable
  # Class for managing instances of Todoable Todo Lists
  # Cannot be initialized directly and is intended as read only objects
  # for API responses.
  # @attr [String] id The uuid of a Todoable List
  # @attr [String] name The name of the List
  # @attr [Array] items The items belonging to the List
  class List
    attr_accessor :id, :name, :items

    # Builds a Todoable::List instance from a json response. Not to be used
    # directly
    # @param [Hash] attributes A hash of parsed JSON returned by Todoable API
    def self.build_from_response(attributes)
      list = new(name: attributes['name'])
      list.id = attributes['id']
      list.items = attributes['items'].map do |item|
        ListItem.build_from_response(item)
      end
      list
    end

    # Seriliazes a not yet persisted List to the JSON shape the Todoable
    # API expects. Not to be used directly.
    def post_body
      {
        "list": {
          "name": name
        }
      }.to_json
    end

    # Determines whether a List is persisted to todoable
    # @return [Boolean] true if persisted, false otherwise
    def persisted
      !id.nil?
    end

    # Hash of instance attribute values, suitable for serialization
    # @return [Hash] A hash of attributes: :id, :name, :items
    def attributes
      {
        id: @id,
        name: @name,
        items: @items.map(&:attributes)
      }
    end

    private

    def initialize(name:)
      @name = name
    end
  end
end
