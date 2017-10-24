module Todoable
  class List

    attr_accessor :id, :name, :items

    def initialize(name: )
      @name = name
    end

    def self.build_from_response(id:, name: , items: )
      list = self.new(name: name)
      list.id = id
      list.items = items
      return list
    end

    def post_body
      {
        "item": {
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
        items: @items,
      }
    end
  end
end
