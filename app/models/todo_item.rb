class TodoItem
  include Mongoid::Document
  field :content, :type => String
  field :priority, :type => Integer
  field :complete, :type => Boolean, :default => -> { false }

  validates_presence_of :content
end
