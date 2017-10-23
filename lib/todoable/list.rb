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

    def as_json
      {
        "item": {
          "name": name
        }
      }
    end

    def persisted
      !!id
    end
  end
end
