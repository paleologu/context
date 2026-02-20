# app/contracts/kinds/assumption_contract.rb
class AssumptionContract < ApplicationContract
  params do
    required(:statement).filled(:string)
    optional(:basis).maybe(:string)
  end
end