module Mutations
  class CreateEntity < BaseMutation
    argument :actor_id,   String, required: true
    argument :kind,       String, required: true
    argument :title,      String, required: true
    argument :summary,    String, required: false
    argument :body,       GraphQL::Types::JSON, required: true
    argument :confidence, Float,  required: false
    argument :scope,      String, required: false

    field :entity, Types::EntityType, null: true
    field :errors, GraphQL::Types::JSON, null: true

    def resolve(**params)
      result = Entities::Create.call(params)
      if result.success?
        { entity: result.value!, errors: nil }
      else
        { entity: nil, errors: result.failure }
      end
    end
  end
end
