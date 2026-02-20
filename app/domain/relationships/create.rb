# app/domain/relationships/create.rb
module Relationships
  class Create
    def self.call(params)
      contract = RelationshipContract.new
      result   = contract.call(params)

      return Failure(result.errors.to_h) if result.failure?

      actor = Actor.find(params[:actor_id])

      relationship = Relationship.create!(
        actor:     actor,
        from_id:   params[:from_id],
        from_type: params[:from_type],
        to_id:     params[:to_id],
        to_type:   params[:to_type],
        predicate: params[:predicate],
        metadata:  params[:metadata] || {}
      )

      Success(relationship)
    end
  end
end