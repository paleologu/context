# app/contracts/kinds/goal_contract.rb
class GoalContract < ApplicationContract
  params do
    required(:statement).filled(:string)
    optional(:success_criteria).maybe(:string)
  end
end