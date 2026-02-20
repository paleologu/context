# spec/integration/knowledge_base_spec.rb
require "rails_helper"

RSpec.describe "Knowledge Base", type: :integration do
  let!(:actor) do
    Actors::FindOrCreate.call(
      ref:  "test@test.com",
      kind: "human",
      name: "Test User"
      )
  end

  # ── Actors ──────────────────────────────────────────────────────────────────

  describe "Actors::FindOrCreate" do
    it "creates a new actor" do
      actor = Actors::FindOrCreate.call(ref: "new@test.com", kind: "human", name: "New User")
      expect(actor).to be_persisted
      expect(actor.kind).to eq("human")
    end

    it "finds an existing actor by ref and kind" do
      first  = Actors::FindOrCreate.call(ref: "same@test.com", kind: "agent", name: "Agent")
      second = Actors::FindOrCreate.call(ref: "same@test.com", kind: "agent", name: "Agent")
      expect(first.id).to eq(second.id)
    end

    it "treats same ref with different kind as different actors" do
      human = Actors::FindOrCreate.call(ref: "dual@test.com", kind: "human", name: "Human")
      agent = Actors::FindOrCreate.call(ref: "dual@test.com", kind: "agent", name: "Agent")
      expect(human.id).not_to eq(agent.id)
    end
  end

  # ── Events ──────────────────────────────────────────────────────────────────

  describe "Events::Record" do
    it "creates an event with the correct attributes" do
      event = Events::Record.call(
        actor:      actor,
        event_type: "source.ingested",
        payload:    { filename: "test.md" },
        scope:      "project-x"
        )

      expect(event).to be_persisted
      expect(event.event_type).to eq("source.ingested")
      expect(event.payload["filename"]).to eq("test.md")
      expect(event.scope).to eq("project-x")
      expect(event.actor).to eq(actor)
    end

    it "is append only — never updates existing events" do
      event = Events::Record.call(actor: actor, event_type: "test.event")
      original_time = event.created_at
      sleep 0.01
      expect { event.update!(event_type: "tampered") }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  # ── Entity Contracts ─────────────────────────────────────────────────────────

  describe "EntityContract" do
    let(:contract) { EntityContract.new }

    it "passes with valid decision params" do
      result = contract.call(
        actor_id:   actor.id,
        kind:       "decision",
        title:      "Use Postgres",
        body:       { chosen_option: "Postgres", rationale: "Native Rails support" }
        )
      expect(result.success?).to be true
    end

    it "fails with invalid kind" do
      result = contract.call(actor_id: actor.id, kind: "nonsense", title: "X", body: {})
      expect(result.failure?).to be true
    end

    it "fails with confidence out of range" do
      result = contract.call(
        actor_id:   actor.id,
        kind:       "decision",
        title:      "X",
        body:       { chosen_option: "X", rationale: "Y" },
        confidence: 1.5
        )
      expect(result.failure?).to be true
    end

    it "fails with missing required decision body fields" do
      result = contract.call(actor_id: actor.id, kind: "decision", title: "X", body: {})
      expect(result.failure?).to be true
    end

    it "fails with invalid actor_id format" do
      result = contract.call(actor_id: "not-a-uuid", kind: "topic", title: "X", body: {})
      expect(result.failure?).to be true
    end
  end

  # ── Entities ─────────────────────────────────────────────────────────────────

  describe "Entities::Create" do
    let(:decision_params) do
      {
        actor_id:   actor.id,
        kind:       "decision",
        title:      "Use Postgres over Neo4j",
        summary:    "Staying with Postgres for the graph layer",
        body:       {
          chosen_option: "Postgres with adjacency lists",
          rationale:     "Simpler ops, native Rails support",
          alternatives:  ["Neo4j", "FalkorDB"],
          assumptions:   ["Graph won't exceed millions of nodes"],
          risks:         ["Performance at scale"]
        },
        confidence: 0.9
      }
    end

    it "succeeds with valid params" do
      result = Entities::Create.call(decision_params)
      expect(result.success?).to be true
    end

    it "creates an entity record" do
      expect { Entities::Create.call(decision_params) }.to change(Entity, :count).by(1)
    end

    it "creates an entity.created event" do
      expect { Entities::Create.call(decision_params) }.to change(Event, :count).by(1)
      expect(Event.last.event_type).to eq("entity.created")
    end

    it "creates an emerged_from relationship to the event" do
      result = Entities::Create.call(decision_params)
      entity = result.value!
      rel = Relationship.from_entity(entity.id).find_by(predicate: "emerged_from")
      expect(rel).to be_present
      expect(rel.to_type).to eq("Event")
    end

    it "sets the correct kind and status" do
      result = Entities::Create.call(decision_params)
      entity = result.value!
      expect(entity.kind).to eq("decision")
      expect(entity.status).to eq("active")
    end

    it "fails with invalid params and returns errors" do
      result = Entities::Create.call(actor_id: actor.id, kind: "bad", title: "X", body: {})
      expect(result.failure?).to be true
      expect(result.failure).to have_key(:kind)
    end

    context "all entity kinds" do
      {
        "learning"    => { statement: "Loose coupling works" },
        "assumption"  => { statement: "Graph stays small" },
        "risk"        => { statement: "Scale issues" },
        "topic"       => { description: "Database architecture" },
        "goal"        => { statement: "Build fast" },
        "constraint"  => { statement: "Must use Postgres" }
      }.each do |kind, body|
        it "creates a #{kind} entity" do
          result = Entities::Create.call(
            actor_id: actor.id,
            kind:     kind,
            title:    "Test #{kind}",
            body:     body
            )
          expect(result.success?).to be true
          expect(result.value!.kind).to eq(kind)
        end
      end
    end
  end

  describe "Entities::Deprecate" do
    let!(:entity) do
      Entities::Create.call(
        actor_id: actor.id,
        kind:     "decision",
        title:    "Old decision",
        body:     { chosen_option: "X", rationale: "Y" }
        ).value!
    end

    it "sets status to deprecated" do
      Entities::Deprecate.call(entity: entity, actor: actor, reason: "Outdated")
      expect(entity.reload.status).to eq("deprecated")
    end

    it "records an entity.deprecated event" do
      expect {
        Entities::Deprecate.call(entity: entity, actor: actor, reason: "Outdated")
      }.to change(Event, :count).by(1)
      expect(Event.where(event_type: "entity.deprecated")).to exist
    end
  end

  describe "Entities::Search" do
    before do
      Entities::Create.call(actor_id: actor.id, kind: "decision", title: "Active decision",
        body: { chosen_option: "X", rationale: "Y" })
      entity = Entities::Create.call(actor_id: actor.id, kind: "learning", title: "A learning",
        body: { statement: "Something learned" }).value!
      Entities::Deprecate.call(entity: entity, actor: actor)
    end

    it "returns active entities by default" do
      result = Entities::Search.call
      expect(result.success?).to be true
      expect(result.value!.map(&:status).uniq).to eq(["active"])
    end

    it "filters by kind" do
      result = Entities::Search.call(kind: "decision")
      expect(result.value!.map(&:kind).uniq).to eq(["decision"])
    end

    it "filters by status" do
      result = Entities::Search.call(status: "deprecated")
      expect(result.value!.map(&:status).uniq).to eq(["deprecated"])
    end
  end

  # ── Relationships ────────────────────────────────────────────────────────────

  describe "Relationships::Create" do
    let!(:entity_a) do
      Entities::Create.call(
        actor_id: actor.id, kind: "decision", title: "Decision A",
        body: { chosen_option: "X", rationale: "Y" }
        ).value!
    end

    let!(:entity_b) do
      Entities::Create.call(
        actor_id: actor.id, kind: "topic", title: "Topic B",
        body: { description: "A topic" }
        ).value!
    end

    it "creates a valid relationship between entities" do
      result = Relationships::Create.call(
        actor_id:  actor.id.to_s,
        from_id:   entity_a.id.to_s,
        from_type: "Entity",
        to_id:     entity_b.id.to_s,
        to_type:   "Entity",
        predicate: "about"
        )
      expect(result.success?).to be true
    end

    it "rejects an invalid predicate" do
      result = Relationships::Create.call(
        actor_id:  actor.id.to_s,
        from_id:   entity_a.id.to_s,
        from_type: "Entity",
        to_id:     entity_b.id.to_s,
        to_type:   "Entity",
        predicate: "invented_predicate"
        )
      expect(result.failure?).to be true
    end

    it "rejects a disallowed from/predicate/to combination" do
      result = Relationships::Create.call(
        actor_id:  actor.id.to_s,
        from_id:   entity_a.id.to_s,
        from_type: "Entity",
        to_id:     entity_b.id.to_s,
        to_type:   "Actor",
        predicate: "emerged_from"
        )
      expect(result.failure?).to be true
    end
  end

  describe "Relationships::PredicateVocabulary" do
    it "allows Entity → emerged_from → Event" do
      expect(Relationships::PredicateVocabulary.allowed?("Entity", "emerged_from", "Event")).to be true
    end

    it "allows Entity → about → Entity" do
      expect(Relationships::PredicateVocabulary.allowed?("Entity", "about", "Entity")).to be true
    end

    it "rejects unknown predicates" do
      expect(Relationships::PredicateVocabulary.allowed?("Entity", "foo", "Entity")).to be false
    end
  end

  # ── Ingestion ────────────────────────────────────────────────────────────────

  describe "Ingestion::Ingest", vcr: true do
    it "creates an event, entities, and relationships from content" do
      content = "We decided to use Postgres over Neo4j because it integrates natively with Rails."

      expect {
        Ingestion::Ingest.call(
          content:     content,
          actor:       actor,
          filename:    "test.md",
          source_type: "transcript"
          )
      }.to change(Entity, :count).by_at_least(1)
      .and change(Event, :count).by_at_least(1)
      .and change(Relationship, :count).by_at_least(1)
    end

    it "records a source.ingested event" do
      Ingestion::Ingest.call(content: "Some content", actor: actor)
      expect(Event.find_by(event_type: "source.ingested")).to be_present
    end
  end

  # ── Ingestion API ────────────────────────────────────────────────────────────

  describe "POST /ingest", type: :request do
    it "returns 404 when actor is not found" do
      post "/ingest", params: {
        actor_id: SecureRandom.uuid,
        content:  "test"
      }, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 when content is missing" do
      post "/ingest", params: { actor_id: actor.id }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end