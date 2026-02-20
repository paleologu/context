# app/contracts/relationship_contract.rb
class RelationshipContract < ApplicationContract
  params do
    required(:actor_id).filled(:string)
    required(:from_id).filled(:string)
    required(:from_type).filled(:string)
    required(:to_id).filled(:string)
    required(:to_type).filled(:string)
    required(:predicate).filled(:string)
    optional(:metadata).maybe(:hash)
  end

  rule(:actor_id) do
    key.failure("must be a valid UUID") unless uuid?(value)
  end

  rule(:from_id) do
    key.failure("must be a valid UUID") unless uuid?(value)
  end

  rule(:to_id) do
    key.failure("must be a valid UUID") unless uuid?(value)
  end

  rule(:from_type, :to_type, :predicate) do
    unless Relationships::PredicateVocabulary.allowed?(
      values[:from_type],
      values[:predicate],
      values[:to_type]
      )
    key(:predicate).failure(
      "#{values[:predicate]} is not allowed from #{values[:from_type]} to #{values[:to_type]}"
      )
  end
end
end
