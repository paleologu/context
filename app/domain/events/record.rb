# app/domain/events/record.rb
module Events
  class Record
    def self.call(actor:, event_type:, payload: {}, metadata: {}, scope: nil)
      Event.create!(
        actor:      actor,
        event_type: event_type,
        payload:    payload,
        metadata:   metadata,
        scope:      scope
      )
    end
  end
end