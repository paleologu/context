# app/domain/entities/deprecate.rb
module Entities
  class Deprecate
    def self.call(entity:, actor:, reason: nil)
      entity.update!(status: "deprecated")

      Events::Record.call(
        actor:      actor,
        event_type: "entity.deprecated",
        payload:    { entity_id: entity.id, reason: reason },
        scope:      entity.scope
      )

      Success(entity)
    end
  end
end