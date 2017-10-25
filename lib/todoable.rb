# frozen_string_literal: true

require 'todoable/version'
# :nodoc:
module Todoable
  autoload :Client, 'todoable/client'
  autoload :Api, 'todoable/api'
  autoload :List, 'todoable/list'
  autoload :ListItem, 'todoable/list_item'
end
