require 'azure/storage'
require 'securerandom'
require 'json'

Azure::Storage.setup({
  storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'],
  storage_access_key: ENV['AZURE_STORAGE_ACCESS_KEY']
})

class AzureStorageTable
  def initialize(table_name, partition_key)
    @table_name = table_name
    @partition_key = partition_key
    @table = create_table_service
  end

  # data must respond_to? to_json
  def create(data, raw = false)
    # TODO: defensively do this, including data to_json
    @table.insert_entity(@table_name, {
      PartitionKey: @partition_key,
      RowKey: SecureRandom.uuid,
      data: raw ? data : data.to_json
    })
    &.properties
    .tap { |result| result['data'] = JSON.parse(result['data']) }
  end

  def find(row_key)
    begin
      @table.get_entity(@table_name, @partition_key, row_key)
        .properties
        .tap { |result| result['data'] = JSON.parse(result['data']) }
    rescue
      nil
    end
  end

  private

  def create_table_service
    Azure::Storage::Table::TableService
      .new
      .tap { |t| t.with_filter(Azure::Storage::Core::Filter::ExponentialRetryPolicyFilter.new) }
  end
end