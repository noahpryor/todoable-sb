# frozen_string_literal: true

module Todoable
  module Api
    # API methods related to ListItemsendpoints
    module ListItem
      # Create a list item for a List of provided ID
      #
      # @param list_id [String] the ID of the list you want to add an item to
      # @param name [String] the new name for the new item
      # @return [Todoable::ListItem] Returns a Todoable::ListItem instance with
      #   a status of :todo
      #
      # @example
      #   client.create_item(list_id: 'list-uuid', name: "Groceries") =>
      #     <Todoable::ListItem
      #       @id='item-uuid'
      #       @list_id='list-uuid'
      #       @name="Take out the trash"
      #       @status=:todo
      #     >
      def create_item(list_id:, name:)
        check_token
        item = Todoable::ListItem.new(name: name)
        response = self.class.post("/lists/#{list_id}/items",
                                   body: item.post_body,
                                   headers: headers)
        check_and_raise_errors(response)
        item.list_id = list_id
        item.id = response.headers['Location'].split('/').last
        item
      end

      # Mark an item as finished
      #
      # @param id [String] the ID of the item you want to finish
      # @param list_id [String] the id of the list the item belongs to
      # @return [true] Returns true if the item was marked as complete,
      #   otherwise raises an error
      #
      # @example
      #   client.finish_item(id: 'uuid', list_id: "list-uuid") =>
      #     true
      def finish_item(id:, list_id:)
        check_token
        response = self.class.put(
          "/lists/#{list_id}/items/#{id}/finish",
          headers: headers
        )
        check_and_raise_errors(response)
        true
      end

      # Delete an item from a list
      #
      # @param id [String] the ID of the item you want to delete
      # @param list_id [String] the id of the list the item belongs to
      # @return [true] Returns true if the item was deleted,
      #   otherwise raises an error
      #
      # @example
      #   client.delete_item(id: 'uuid', list_id: "list-uuid") =>
      #     true
      def delete_item(id:, list_id:)
        check_token
        response = self.class.delete(
          "/lists/#{list_id}/items/#{id}",
          headers: headers
        )
        check_and_raise_errors(response)
        true
      end
    end
  end
end
