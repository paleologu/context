# app/domain/relationships/predicate_vocabulary.rb
module Relationships
  module PredicateVocabulary
    ALL = %w[
      emerged_from
      made_by
      extracted_by
      about
      related_to
      informed_by
      contradicts
      validates
      supersedes
      depends_on
      caused_by
      triggered_by
    ].freeze

    ALLOWED = [
      { from: "Entity", predicate: "emerged_from",  to: "Event"  },
      { from: "Entity", predicate: "made_by",       to: "Actor"  },
      { from: "Entity", predicate: "extracted_by",  to: "Actor"  },
      { from: "Entity", predicate: "about",         to: "Entity" },
      { from: "Entity", predicate: "related_to",    to: "Entity" },
      { from: "Entity", predicate: "informed_by",   to: "Entity" },
      { from: "Entity", predicate: "contradicts",   to: "Entity" },
      { from: "Entity", predicate: "validates",     to: "Entity" },
      { from: "Entity", predicate: "supersedes",    to: "Entity" },
      { from: "Entity", predicate: "depends_on",    to: "Entity" },
      { from: "Entity", predicate: "caused_by",     to: "Event"  },
      { from: "Entity", predicate: "triggered_by",  to: "Entity" },
    ].freeze

    def self.allowed?(from_type, predicate, to_type)
      ALLOWED.any? do |rule|
        rule[:from] == from_type &&
        rule[:predicate] == predicate &&
        rule[:to] == to_type
      end
    end
  end
end