module Todoable
  class ListItem
    attr_accessor :id, :list_id, :name, :status

    def initialize(name: )
      @name = name
      @status = :todo
    end

    def self.build_from_response(attributes)
      status = attributes['finished_at'].nil? ? :todo : :done
      item = new(name: attributes['name'])
      item.id = attributes['id'] || attributes['src'].split('/').last
      item.list_id = attributes['src'].split('/')[-3]
      item.status = status
      item
    end

    # def self.build_from_response(id: , list_id: , name: , status: )
    #   item = new(name: name)
    #   item.id = id
    #   item.list_id = list_id
    #   item.status = status
    #   item
    # end

    def post_body
      {
        "item": {
          "name": name
        }
      }.to_json
    end

    def persisted
      !!id && !!list_id
    end

    def attributes
      {
        id: @id,
        name: @name,
        status: @status,
        list_id: @list_id
      }
    end

  end
end
