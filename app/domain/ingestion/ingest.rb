module Ingestion
  class Ingest
    def self.call(content:, actor:, filename: nil, source_type: "raw")
      event = Events::Record.call(
        actor:      actor,
        event_type: "source.ingested",
        payload:    {
          filename:    filename,
          source_type: source_type,
          byte_size:   content.bytesize
        }
      )

      extraction = Ingestion::Extract.call(content: content)
      return extraction if extraction.failure?

      data     = extraction.value!
      entities = data["entities"]
      rels     = data["relationships"] || []

      created_entities = []
      entities.each do |entity_params|
        result = Entities::Create.call(
          actor_id:   actor.id.to_s,
          kind:       entity_params["kind"],
          title:      entity_params["title"],
          summary:    entity_params["summary"],
          body:       entity_params["body"],
          confidence: entity_params["confidence"]
        )

        if result.success?
          created_entities << result.value!
        else
          Rails.logger.warn("Entity creation failed: #{result.failure}")
          created_entities << nil
        end
      end

      rels.each do |rel|
        from_entity = created_entities[rel["from_index"]]
        to_entity   = created_entities[rel["to_index"]]
        next unless from_entity && to_entity

        Relationships::Create.call({
          actor_id:  actor.id.to_s,
          from_id:   from_entity.id.to_s,
          from_type: "Entity",
          to_id:     to_entity.id.to_s,
          to_type:   "Entity",
          predicate: rel["predicate"]
        })
      end

      created_entities.compact.each do |entity|
        Relationships::Create.call({
          actor_id:  actor.id.to_s,
          from_id:   entity.id.to_s,
          from_type: "Entity",
          to_id:     event.id.to_s,
          to_type:   "Event",
          predicate: "emerged_from"
        })
      end

      Success({
        event:    event,
        entities: created_entities.compact
      })
    end
  end
end
