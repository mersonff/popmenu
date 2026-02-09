class Import < ApplicationRecord
  STATUSES = %w[pending processing completed failed].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :input_data, presence: true

  def pending?
    status == "pending"
  end

  def processing?
    status == "processing"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def finished?
    completed? || failed?
  end
end
