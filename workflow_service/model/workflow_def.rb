require "action_handler_map"
require "step_map"
require "mongoid"

class WorkflowDef

  include Mongoid::Document

  field :id, type: String
  field :description, type: String
  embeds_one :action_handlers, class_name: "ActionHandlerMap"


end