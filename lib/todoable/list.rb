module Todoable
  class List

    attr_accessor :id, :name, :items

    def initialize(name: )
      @name = name
    end

    def self.build_from_response(attributes)
      list = self.new(name: attributes['name'])
      list.id = attributes['id']
      list.items = attributes['items'].map do |item|
        ListItem.build_from_response(item)
      end
      return list
    end

    # def self.build_from_response(id:, name: , items: )
    #   list = self.new(name: name)
    #   list.id = id
    #   list.items = items
    #   return list
    # end

    def post_body
      {
        "list": {
          "name": name
        }
      }.to_json
    end

    def persisted
      !!id
    end

    def attributes
      {
        id: @id,
        name: @name,
        items: @items.map(&:attributes),
      }
    end
  end
end
