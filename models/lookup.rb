class Lookup
  include Mongoid::Document
  include Mongoid::Timestamps
  field :number, String
  field :response, Array
end