##
# Controller for listing available currency codes.
#
# @example GET /currencies
#   ["EUR", "GBP", "USD", ...]
#
# Returns a JSON array of currency codes, sorted alphabetically.
class CurrenciesController < ActionController::API
  # GET /currencies
  #
  # Returns a JSON array of currency codes, sorted alphabetically.
  #
  # @return [Array<String>] currency codes
  def index
    render json: Currency.order(:code).pluck(:code)
  end
end
