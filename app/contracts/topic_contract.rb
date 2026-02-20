# app/contracts/kinds/topic_contract.rb
class TopicContract < ApplicationContract
  params do
    optional(:description).maybe(:string)
  end
end