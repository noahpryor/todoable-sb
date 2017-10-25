# frozen_string_literal: true

module Todoable
  module Api
    # API methods related to List endpoints
    module List
      # Fetch all todoable lists for authenticated user
      #
      #
      # @return [Array] An array of Todoable list instances
      #   without included items
      #
      # @example
      #   client.lists =>
      #    [ <Todoable::List @name="Urgent Tasks", @id="uuid" @items=[]>,
      #      <Todoable::List @name="Regular Tasks", @id="uuid" @items=[]>
      #    ]
      def lists
        check_token
        response = self.class.get('/lists', headers: headers)
        check_and_raise_errors(response)
        response.parsed_response['lists'].map do |json|
          attributes = json.merge!(
            'items' => [],
            'id' => json['src'].split('/').last
          )
          Todoable::List.build_from_response(attributes)
        end
      end

      # Fetch a todoable list by ID for authenticated user
      #
      # @param id [String] The id of the list you want to fetch
      # @return [Array] A Todoable list instance with included items
      #
      # @example
      #   client.find_list('todo-able-list-uuid') =>
      #     <Todoable::List @name="Urgent Tasks",
      #       @id="todo-able-list-uuid"
      #       @items=[ <Todoable::ListItem>, <Todoable::ListItem>]
      #     >
      #
      #
      def find_list(id)
        check_token
        response = self.class.get("/lists/#{id}", headers: headers)
        check_and_raise_errors(response)
        Todoable::List.build_from_response(response.parsed_response)
      end

      # Create a list with a name
      #
      # @param name [String] the name for the new List
      # @return [Todoable::List] A Todoable list instance
      #
      # @example
      #   client.create_list(name: "Urgent Tasks") =>
      #     <Todoable::List @name="Urgent Tasks", @id="uuid" @items=[]>
      def create_list(name:)
        check_token
        list = Todoable::List.new(name: name)
        response = self.class.post(
          '/lists', body: list.post_body, headers: headers
        )
        check_and_raise_errors(response)
        attributes = response.parsed_response.merge!('items' => [])
        Todoable::List.build_from_response(attributes)
      end

      # Update a list with a new name
      #
      # @param list_id [String] the ID of the list you want to update
      # @param name [String] the new name for the List
      # @return [true] Returns true if the list was successfully updated,
      #   otherwise raises an error
      #
      # @example
      #   client.update_list(id: 'uuid', name: "Urgent Tasks") =>
      #     true
      def update_list(list_id:, name:)
        check_token
        list = Todoable::List.new(name: name)
        response = self.class.patch(
          "/lists/#{list_id}",
          body: list.post_body,
          headers: headers,
          format: :text
        )
        check_and_raise_errors(response)
        # This endpoint returns a plaintext body: "<new name> updated", so
        # while I'd like to return a List with ListItems, that would require
        # first looking up the list which isn't ideal. So we'll return true, ask
        # todoable to fix this endpoint, and make developers keep track of the
        # name change
        true
      end

      # Delete a list and its items for an authenticated user
      #
      # @param id [String] the ID of the list you want to delete
      # @return [true] Returns true if the list was successfully deleted,
      #   otherwise raises an error
      #
      # @example
      #   client.delete_list(id: 'uuid') =>
      #     true
      def delete_list(id:)
        check_token
        response = self.class.delete("/lists/#{id}", headers: headers)
        check_and_raise_errors(response)
        true
      end
    end
  end
end
