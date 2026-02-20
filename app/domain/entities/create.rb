module Entities
  class Create
    def self.call(params)
      contract = EntityContract.new
      result   = contract.call(params)

      return Failure(result.errors.to_h) if result.failure?

      actor = Actor.find(params[:actor_id])

      event = Events::Record.call(
        actor:      actor,
        event_type: "entity.created",
        payload:    params,
        scope:      params[:scope]
      )

      entity = Entity.create!(
        actor:      actor,
        kind:       params[:kind],
        title:      params[:title],
        summary:    params[:summary],
        body:       params[:body],
        status:     params[:status] || "active",
        confidence: params[:confidence],
        scope:      params[:scope]
      )

      Relationships::Create.call({
        actor_id:  actor.id.to_s,
        from_id:   entity.id.to_s,
        from_type: "Entity",
        to_id:     event.id.to_s,
        to_type:   "Event",
        predicate: "emerged_from"
      })

      Success(entity)
    end
  end
end