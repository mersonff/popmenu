class ImportJob < ApplicationJob
  queue_as :default

  def perform(import_id)
    import = Import.find(import_id)
    import.update!(status: "processing")

    result = JsonImportService.new(data: import.input_data).call

    if result.success?
      import.update!(status: "completed", result_data: result.data)
    else
      import.update!(status: "failed", error_message: result.error)
    end
  rescue => e
    import&.update!(status: "failed", error_message: e.message) if import&.persisted?
    raise
  end
end
