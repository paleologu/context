# config/initializers/dry.rb
require "dry/validation"
require "dry/struct"

Dry::Validation.load_extensions(:monads)

include Dry::Monads[:result]
