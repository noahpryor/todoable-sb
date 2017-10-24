module Todoable
  module Api
    module ListItem

      def create_item(list_id: , name: )
        item = Todoable::ListItem.new(name: name)
        response = self.class.post("/lists/#{list_id}/items", body: item.as_json, headers: headers)
        check_and_raise_errors(response)
        item.list_id = list_id
        begin
          id = response.headers['Location'].split("/").last
        rescue
          id =  "todoable-missing-location-header"
        end
        item.id = id
        return item
      end

      def add_item(list: , item: )
        raise ArgumentError unless list.is_a?(Todoable::List) &&
          item.is_a?(Todoable::ListItem)
        response = self.class.post("/lists/#{list.id}/items", body: item.as_json, headers: headers)
        check_and_raise_errors(response)
        begin
          id = response.headers['Location'].split("/").last
        rescue
          id = "todoable-missing-location-header"
        end
        item.id = id
        item.list_id = list.id
        list.items << item
        return list
      end

      def finish_item(item: )
        raise ArgumentError unless item.is_a?(Todoable::ListItem) && item.persisted
        response = self.class.put("/lists/#{item.list_id}/items/#{item.id}/finish", headers: headers)
        check_and_raise_errors(response)
        item.status = :done
        return item
      end

      def delete_item(item: )
        raise ArgumentError unless item.is_a?(Todoable::ListItem) && item.persisted
        response = self.class.delete("/lists/#{item.list_id}/items/#{item.id}", headers: headers)
        check_and_raise_errors(response)
        return true # maybe this should return the List we deleted from?
      end

    end
  end
end
