module Mutations
  class DeprecateEntity < BaseMutation
    argument :entity_id, String, required: true
    argument :actor_id,  String, required: true
    argument :reason,    String, required: false

    field :entity, Types::EntityType, null: true
    field :errors, GraphQL::Types::JSON, null: true

    def resolve(entity_id:, actor_id:, reason: nil)
      entity = Entity.find_by(id: entity_id)
      actor  = Actor.find_by(id: actor_id)

      return { entity: nil, errors: { base: "Entity not found" } } unless entity
      return { entity: nil, errors: { base: "Actor not found" } }  unless actor

      result = Entities::Deprecate.call(entity: entity, actor: actor, reason: reason)
      if result.success?
        { entity: result.value!, errors: nil }
      else
        { entity: nil, errors: result.failure }
      end
    end
  end
end
