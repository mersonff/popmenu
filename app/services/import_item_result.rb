class ImportItemResult
  STATUSES = %i[created existing failed].freeze

  attr_reader :status, :name, :error

  def initialize(status:, name:, error: nil)
    raise ArgumentError, "Invalid status: #{status}" unless STATUSES.include?(status)

    @status = status
    @name = name
    @error = error
  end

  def created?
    status == :created
  end

  def existing?
    status == :existing
  end

  def failed?
    status == :failed
  end

  def to_h
    hash = { name: name, status: status }
    hash[:error] = error if failed?
    hash
  end
end
