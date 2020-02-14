require "mongoid"

class ActionHandler
  include Mongoid::Document
  field :type, type: String
  field :url, type: String

  def initialize(type:, url:)
    @type = type
    @url = url
  end
end
