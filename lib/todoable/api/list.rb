module Todoable
  module Api
    module List

      def lists
        response = self.class.get('/lists', {headers: headers})
        check_and_raise_errors(response)
        response.parsed_response["lists"].map do |json|
          id = json["src"].split("/").last # HACK
          Todoable::List.build_from_response(id: id, name: json['name'], items: [])
        end
      end

      def find_list(id)
        response = self.class.get("/lists/#{id}", {headers: headers})
        check_and_raise_errors(response)
        attributes = response.parsed_response

        items = attributes["items"].map do |item_json|
          item_id = item_json["src"].split("/").last # HACK
          Todoable::ListItem.build_from_response(
            id: item_id,
            list_id: id,
            name: item_json["name"],
            status: item_json['finished_at'].nil? ? :todo : :done
          )
        end

        Todoable::List.build_from_response(id: id, name: attributes["name"], items: items)
      end

      def create_list(list_id: , name: )
        list = Todoable::List.new(name: name)
        save_list(list: list)
      end

      def save_list(list: )
        raise ArgumentError unless list.is_a?(Todoable::List)
        response = self.class.post('/lists', body: list.as_json, headers: headers)
        check_and_raise_errors(response)
        begin
          id = response.headers['Location'].split("/").last
        rescue
          id = "todoable-missing-location-header"
        end
        # TODO: I'm not seeing a location header on list creation
        Todoable::List.build_from_response(id: id, name: list.name, items: [])
      end

      def update(list: , name: )
        raise ArgumentError unless list.is_a?(Todoable::List) && list.persisted
        response = self.class.patch("/lists/#{list.id}", body: list.as_json, headers: headers)
        check_and_raise_errors(response)

        # HACK
        begin
          id = response.headers['Location'].split("/").last
        rescue
          id = "todoable-missing-location-header"
        end
        # TODO: I'm not seeing a location header on list response
        list.name = name
        return list
      end

      def delete(list: )
        raise ArgumentError unless list.is_a?(Todoable::List) && list.persisted
        response = self.class.delete("/lists/#{list.id}", headers: headers)
        check_and_raise_errors(response)
        return true
      end
    end
  end
end
