# app/contracts/application_contract.rb
class ApplicationContract < Dry::Validation::Contract
  config.messages.backend = :i18n

  private

  def uuid?(value)
    value.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
  end
end