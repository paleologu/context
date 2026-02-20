# app/contracts/kinds/learning_contract.rb
class LearningContract < ApplicationContract
  params do
    required(:statement).filled(:string)
    optional(:evidence_summary).maybe(:string)
    optional(:scope).maybe(:string)
  end
end