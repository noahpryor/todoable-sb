module Todoable
  module Api
    module List
      def lists
        response = self.class.get('/lists', headers: headers)
        check_and_raise_errors(response)
        response.parsed_response['lists'].map do |json|
          id = json['src'].split('/').last # HACK
          Todoable::List.build_from_response(id: id, name: json['name'], items: [])
        end
      end

      def find_list(id)
        response = self.class.get("/lists/#{id}", headers: headers)
        check_and_raise_errors(response)
        attributes = response.parsed_response

        items = attributes['items'].map do |item_json|
          item_id = item_json['src'].split('/').last # HACK
          Todoable::ListItem.build_from_response(
            id: item_id,
            list_id: id,
            name: item_json['name'],
            status: item_json['finished_at'].nil? ? :todo : :done
          )
        end

        Todoable::List.build_from_response(id: id, name: attributes['name'], items: items)
      end

      def create_list(name:)
        list = Todoable::List.new(name: name)
        response = self.class.post('/lists', body: list.post_body, headers: headers)
        check_and_raise_errors(response)
        id = response.headers['Location'].split('/').last
        Todoable::List.build_from_response(id: id, name: list.name, items: [])
      end

      def update(list_id:, name:)
        list = Todoable::List.new(name: name)
        response = self.class.patch("/lists/#{list_id}", body: list.post_body, headers: headers, format: :text)
        check_and_raise_errors(response)
        # This endpoint returns a plaintext body: "<new name> updated", so
        # while I'd like to return a List with ListItems, that would require
        # first looking up the list which isn't ideal. So we'll return true, ask
        # todoable to fix this endpoint, and make developers keep track of the
        # name change
        true
      end

      def delete_list(id:)
        response = self.class.delete("/lists/#{id}", headers: headers)
        check_and_raise_errors(response)
        true
      end
    end
  end
end
