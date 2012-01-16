class TodoItem
  include Mongoid::Document
  field :content, :type => String
  field :priority, :type => Integer
  field :complete, :type => Boolean, :default => -> { false }
  field :completed_on, :type => Date
  field :user_id, :type => BSON::ObjectId

  validates_presence_of :content
end
