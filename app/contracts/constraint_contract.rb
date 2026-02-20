# app/contracts/kinds/constraint_contract.rb
class ConstraintContract < ApplicationContract
  params do
    required(:statement).filled(:string)
    optional(:source).maybe(:string)
  end
end