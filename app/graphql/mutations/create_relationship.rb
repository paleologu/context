module Mutations
  class CreateRelationship < BaseMutation
    argument :actor_id,  String, required: true
    argument :from_id,   String, required: true
    argument :from_type, String, required: true
    argument :to_id,     String, required: true
    argument :to_type,   String, required: true
    argument :predicate, String, required: true
    argument :metadata,  GraphQL::Types::JSON, required: false

    field :relationship, Types::RelationshipType, null: true
    field :errors,       GraphQL::Types::JSON,    null: true

    def resolve(**params)
      result = Relationships::Create.call(params)
      if result.success?
        { relationship: result.value!, errors: nil }
      else
        { relationship: nil, errors: result.failure }
      end
    end
  end
end
