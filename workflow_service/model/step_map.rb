require "mongoid"

class StepMap
  include Mongoid::Document

  def initialize(handlers = {})
    @handlers = handlers
  end

  def mongoize
    @handlers
  end

  class << self
    def demongoize(object)
      handlers = object.map { |k, v| [k.to_sym, object] }.to_h
      StepMap.new(handlers)
    end

    def mongoize(object)
      case object
      when StepMap then object.mongoize
      else object
      end
    end

    def evolve(object)
      case object
      when StepMap then object.mongoize
      else object
      end
    end
  end
end
