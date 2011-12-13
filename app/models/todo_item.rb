class TodoItem
  include Mongoid::Document
  field :content, :type => String
  field :priority, :type => Integer
end
