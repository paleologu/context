class RiskContract < ApplicationContract
  params do
    required(:statement).filled(:string)
    optional(:likelihood).maybe(:string)
    optional(:impact).maybe(:string)
    optional(:mitigation).maybe(:string)
  end
end
