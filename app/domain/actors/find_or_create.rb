# app/domain/actors/find_or_create.rb
module Actors
  class FindOrCreate
    def self.call(ref:, kind:, name:, metadata: {})
      Actor.find_or_create_by!(ref: ref, kind: kind) do |actor|
        actor.name     = name
        actor.metadata = metadata
      end
    end
  end
end