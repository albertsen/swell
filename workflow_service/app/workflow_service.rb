$LOAD_PATH << "#{__dir__}/../model"

require "sinatra"
require "mongoid"
require "net/http"
require "workflow_def"

Mongoid.load! "mongoid.config"

# create a new order and notify shipping service about new order
post "/workflowdefs" do
  doc = JSON.parse(request.body.read)
  workflow_def = WorkflowDef.new(doc)
  if workflow_def.save
    status HTTPStatus::CREATED
  else
    status HTTPStatus::UNPROCESSABLE_ENTRY
  end
end

get "/workflowdefs/:id" do
	id = params[:id]
  workflow_def = WorkflowDef.find(id)
  content_type :json
  if workflow_def
    status HTTPStatus::OK
    body workflow_def.to_json  
  else
    status HTTPStatus::NOT_FOUND
  end
end

module HTTPStatus
  OK = 200
  CREATED = 201
  NOT_FOUND = 404
  UNPROCESSABLE_ENTRY = 422
end
