# frozen_string_literal: true

module Todoable
  # Class for managing instances of Todoable Todo List items (Todos).
  # Cannot be initialized directly and is intended as read only objects
  # for API responses.
  # @attr [String] id The uuid of a Todoable List Item
  # @attr [String] list_id The uuid of a Todoable List this Item belongs to
  # @attr [String] name The name of the Item
  # @attr [Symbol] status The completion status of the Item,
  #  either :todo or :completed
  class ListItem
    attr_accessor :id, :list_id, :name, :status

    # Builds a Todoable::ListItem from a json response. Not to be used
    # directly
    # @param [Hash] attributes A hash of parsed JSON returned by Todoable API
    def self.build_from_response(attributes)
      status = attributes['finished_at'].nil? ? :todo : :done
      item = new(name: attributes['name'])
      item.id = attributes['id'] || attributes['src'].split('/').last
      item.list_id = attributes['src'].split('/')[-3]
      item.status = status
      item
    end

    # Seriliazes a not yet persisted ListItem to the JSON shape the Todoable
    # API expects. Not to be used directly.
    def post_body
      {
        "item": {
          "name": name
        }
      }.to_json
    end

    # Determines whether a ListItem is persisted to todoable
    # @return [Boolean] true if persisted, false otherwise
    def persisted
      [id, list_id].compact.length == 2
    end

    # Hash of instance attribute values, suitable for serialization
    # @return [Hash] A hash of attributes: :id, :name, :status, :list_id
    def attributes
      {
        id: @id,
        name: @name,
        status: @status,
        list_id: @list_id
      }
    end

    private

    def initialize(name:)
      @name = name
      @status = :todo
    end
  end
end
