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
  #     "target_currency_code": "EUR",
  #     "source_amount": 100
  #   }
  #
  # POST /convert
  def create
    target_amount = ConversionsService.convert(
      source_currency_code: params[:source_currency_code],
      target_currency_code: params[:target_currency_code],
      amount: params[:source_amount].to_f
    )

    conversion = Conversion.new(
      source_currency_code: params[:source_currency_code],
      target_currency_code: params[:target_currency_code],
      source_amount: params[:source_amount].to_f,
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
end
