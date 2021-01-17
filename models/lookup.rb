class Lookup
  include Mongoid::Document
  include Mongoid::Timestamps
  field :number, type: String
  field :response, type: Array
end