Rails.application.config.after_initialize do
  # Only seed in development if currencies table is empty
  if Rails.env.development? && Currency.table_exists? && Currency.count.zero?
    Rails.logger.info "Seeding database..."

    Rails.application.load_seed
  end
end
