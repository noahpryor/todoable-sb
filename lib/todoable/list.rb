module Todoable
  class List

    attr_accessor :id, :name, :items

    def initialize(id: ,name: , items: )
      @id, @name, @items = id, name, items
    end

    def update(name: )
      # TODO: call API
      @name = name
    end

    def add_item(item)
      raise ArgumentError if item.class != ListItem
      # TODO: call API duh
      @items << item
    end

    class << self
      def all
        []
      end

      def create(name: )
        # TODO: call API to get ID and items
        self.new(
          id: "this-should-be-a-real-id",
          name: name,
          items: []
        )
      end

      def find(id)
        # TODO: call API to get name and items
        List.new(
          id: id,
          name: "this-should-be-a-real-name",
          items: []
        )
      end

    end

  end
end
