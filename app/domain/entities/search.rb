# app/domain/entities/search.rb
module Entities
  class Search
    def self.call(kind: nil, status: "active", scope: nil, query_embedding: nil, limit: 20)
      scope_rel = Entity.all
      scope_rel = scope_rel.where(kind: kind)         if kind
      scope_rel = scope_rel.where(status: status)     if status
      scope_rel = scope_rel.where(scope: scope)       if scope

      if query_embedding
        scope_rel = scope_rel
          .nearest_neighbors(:embedding, query_embedding, distance: "cosine")
          .limit(limit)
      else
        scope_rel = scope_rel.order(created_at: :desc).limit(limit)
      end

      Success(scope_rel)
    end
  end
end