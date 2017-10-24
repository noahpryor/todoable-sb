module Todoable
  module Api
    module ListItem
      def create_item(list_id:, name:)
        item = Todoable::ListItem.new(name: name)
        response = self.class.post("/lists/#{list_id}/items", body: item.post_body, headers: headers)
        check_and_raise_errors(response)
        item.list_id = list_id
        id = response.headers['Location'].split('/').last
        item.id = id
        item
      end

      def finish(id:, list_id:)
        response = self.class.put("/lists/#{list_id}/items/#{id}/finish", headers: headers)
        check_and_raise_errors(response)
        true
      end

      def delete(id:, list_id:)
        response = self.class.delete("/lists/#{list_id}/items/#{id}", headers: headers)
        check_and_raise_errors(response)
        true
      end
    end
  end
end
