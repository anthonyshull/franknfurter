# Controller for handling currency conversion operations.
class ConversionsController < ActionController::API
  # Creates a new currency conversion.
  #
  # Converts an amount from source currency to target currency using current
  # exchange rates and stores the conversion record in the database.
  #
  # @example POST /convert
  #   {
  #     "source_currency_code": "USD",
  #     "target_currency_code": "MXN",
  #     "source_amount": 100
  #   }
  #
  # POST /convert
  def create
    return render json: { error: "Missing required parameters" }, status: :bad_request unless conversion_params_present?

    target_amount = ConversionsService.convert(
      source_currency_code: conversion_params[:source_currency_code],
      target_currency_code: conversion_params[:target_currency_code],
      amount: BigDecimal(conversion_params[:source_amount])
    )

    return render json: { error: "Exchange rate not found" }, status: :unprocessable_entity if target_amount.nil?

    conversion = Conversion.new(
      source_currency_code: conversion_params[:source_currency_code],
      target_currency_code: conversion_params[:target_currency_code],
      source_amount: BigDecimal(conversion_params[:source_amount]),
      target_amount: target_amount
    )

    if conversion.save
      render json: ConversionBlueprint.render(conversion), status: :created
    else
      render json: { errors: conversion.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Conversion failed: #{e.message}" }, status: :bad_request
  end

  # Retrieves the 10 most recent conversions.
  #
  # @example GET /conversions
  #   Returns array of conversion records ordered by created_at desc
  #
  # GET /conversions
  def index
    conversions = Conversion.order(created_at: :desc).limit(10)

    render json: ConversionBlueprint.render(conversions)
  end

  private

  def conversion_params
    params.permit(:source_currency_code, :target_currency_code, :source_amount)
  end

  def conversion_params_present?
    conversion_params[:source_currency_code].present? &&
      conversion_params[:target_currency_code].present? &&
      conversion_params[:source_amount].present?
  end
end
