# spec/domain/entities/create_spec.rb
require "rails_helper"

RSpec.describe Entities::Create do
  let(:actor) { Actors::FindOrCreate.call(ref: "test@test.com", kind: "human", name: "Test") }

  describe ".call" do
    context "with valid decision params" do
      let(:params) do
        {
          actor_id:   actor.id,
          kind:       "decision",
          title:      "Use Postgres over Neo4j",
          summary:    "We decided to stay with Postgres for the graph layer",
          body:       {
            chosen_option: "Postgres with adjacency lists",
            rationale:     "Simpler ops, good enough for our scale",
            alternatives:  ["Neo4j", "FalkorDB"],
            assumptions:   ["We won't exceed millions of relationships"],
            risks:         ["Graph traversal performance at scale"]
          },
          confidence: 0.9
        }
      end

      it "succeeds" do
        result = described_class.call(params)
        expect(result.success?).to be true
      end

      it "creates an entity" do
        expect { described_class.call(params) }.to change(Entity, :count).by(1)
      end

      it "creates an event" do
        expect { described_class.call(params) }.to change(Event, :count).by(1)
      end

      it "creates an emerged_from relationship" do
        result = described_class.call(params)
        entity = result.value!
        relationships = Relationship.from_entity(entity.id)
        expect(relationships.map(&:predicate)).to include("emerged_from")
      end

      it "sets the correct kind" do
        result = described_class.call(params)
        expect(result.value!.kind).to eq("decision")
      end
    end

    context "with invalid params" do
      it "fails with missing required body fields" do
        result = described_class.call(
          actor_id: actor.id,
          kind:     "decision",
          title:    "Missing body fields",
          body:     {}
        )
        expect(result.failure?).to be true
      end

      it "fails with invalid kind" do
        result = described_class.call(
          actor_id: actor.id,
          kind:     "nonsense",
          title:    "Bad kind",
          body:     {}
        )
        expect(result.failure?).to be true
      end
    end
  end
end