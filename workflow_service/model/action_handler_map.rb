require "action_handler"
require "mongoid"

class ActionHandlerMap
  include Mongoid::Document

  def initialize(handlers = {})
    @handlers = handlers
  end

  def mongoize
    @handlers
  end

  class << self
    def demongoize(object)
      handlers = (object.map do |k, v|
        [k.to_sym, ActionHandler.new(type: object["type"], url: object["url"])]
      end).to_h
      ActionHandlerMap.new(handlers)
    end

    def mongoize(object)
      case object
      when ActionHandlerMap then object.mongoize
      else object
      end
    end

    def evolve(object)
      case object
      when ActionHandlerMap then object.mongoize
      else object
      end
    end
  end
end
