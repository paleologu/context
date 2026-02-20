class EntityContract < ApplicationContract
  KINDS = %w[decision learning assumption risk topic goal constraint].freeze
  STATUSES = %w[active deprecated superseded].freeze

  params do
    required(:actor_id).filled(:string)
    required(:kind).filled(:string)
    required(:title).filled(:string)
    optional(:summary).maybe(:string)
    required(:body).filled(:hash)
    optional(:status).filled(:string)
    optional(:confidence).maybe(:float)
    optional(:scope).maybe(:string)
  end

  rule(:actor_id) do
    key.failure("must be a valid UUID") unless uuid?(value)
  end

  rule(:kind) do
    key.failure("must be one of: #{KINDS.join(", ")}") unless KINDS.include?(value)
  end

  rule(:status) do
    next unless value
    key.failure("must be one of: #{STATUSES.join(", ")}") unless STATUSES.include?(value)
  end

  rule(:confidence) do
    next unless value
    key.failure("must be between 0.0 and 1.0") unless value.between?(0.0, 1.0)
  end

  rule(:kind, :body) do
    kind_contract = case values[:kind]
    when "decision"   then DecisionContract.new
    when "learning"   then LearningContract.new
    when "assumption" then AssumptionContract.new
    when "risk"       then RiskContract.new
    when "topic"      then TopicContract.new
    when "goal"       then GoalContract.new
    when "constraint" then ConstraintContract.new
    end

    next unless kind_contract

    result = kind_contract.call(values[:body])
    result.errors.to_h.each do |field, messages|
      key(:"body.#{field}").failure(messages.first)
    end
  end
end
