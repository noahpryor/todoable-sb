# frozen_string_literal: true

module Todoable
  module Api
    # API methods related to List endpoints
    module List
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

      def find_list(id)
        check_token
        response = self.class.get("/lists/#{id}", headers: headers)
        check_and_raise_errors(response)
        Todoable::List.build_from_response(response.parsed_response)
      end

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

      def delete_list(id:)
        check_token
        response = self.class.delete("/lists/#{id}", headers: headers)
        check_and_raise_errors(response)
        true
      end
    end
  end
end
