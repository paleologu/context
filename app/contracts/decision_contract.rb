# app/contracts/kinds/decision_contract.rb
class DecisionContract < ApplicationContract
  params do
    required(:chosen_option).filled(:string)
    required(:rationale).filled(:string)
    optional(:alternatives).maybe(:array)
    optional(:assumptions).maybe(:array)
    optional(:risks).maybe(:array)
  end
end
