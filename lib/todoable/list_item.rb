module Todoable
  class ListItem
    attr_accessor :id, :list_id, :name, :status

    def initialize(name:)
      @name = name
      @status = :todo
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
