# Load the rails application
require File.expand_path('../application', __FILE__)

require 'action_controller/middleware_stack' unless defined? ::ActionController::MiddlewareStack
#Encoding.default_external = Encoding::UTF_8
#Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
Patrick::Application.initialize!