# frozen_string_literal: true
module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, null: true], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ID], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :entities, [Types::EntityType], null: false do
      argument :kind,   String, required: false
      argument :status, String, required: false, default_value: "active"
      argument :scope,  String, required: false
    end

    def entities(kind: nil, status: "active", scope: nil)
      result = Entities::Search.call(kind: kind, status: status, scope: scope)
      result.success? ? result.value! : []
    end

    field :entity, Types::EntityType, null: true do
      argument :id, ID, required: true
    end

    def entity(id:)
      Entity.find_by(id: id)
    end

    field :actors, [Types::ActorType], null: false

    def actors
      Actor.all
    end

    field :actor, Types::ActorType, null: true do
      argument :ref, String, required: true
    end

    def actor(ref:)
      Actor.find_by(ref: ref)
    end

    field :events, [Types::EventType], null: false do
      argument :event_type, String, required: false
      argument :scope,      String, required: false
    end

    def events(event_type: nil, scope: nil)
      result = Event.all
      result = result.by_type(event_type) if event_type
      result = result.by_scope(scope)     if scope
      result.recent
    end

    field :relationships, [Types::RelationshipType], null: false do
      argument :from_id,   ID,     required: false
      argument :predicate, String, required: false
    end

    def relationships(from_id: nil, predicate: nil)
      result = Relationship.all
      result = result.from_entity(from_id)    if from_id
      result = result.by_predicate(predicate) if predicate
      result
    end
  end
end