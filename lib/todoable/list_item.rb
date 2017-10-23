module Todoable
  class ListItem
    attr_accessor :id, :list_id, :name, :status

    def initialize(name: )
      @name = name
      @status = :todo
    end

    def self.build_from_response(id: , list_id: , name: , status: )
      item = new(name: name)
      item.id = id
      item.list_id = list_id
      item.status = status
      item
    end

    def as_json
      {
        "item": {
          "name": name
        }
      }
    end

    def finish
      #TODO: call API
      @status = :finished
    end

    def destroy
      #TODO: implement this
    end

  end
end
