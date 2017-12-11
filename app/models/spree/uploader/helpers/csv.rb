# Helper class for CSV files uploading
class Spree::Uploader::Helpers::Csv
  def initialize(file_name)
    @file_name = file_name
  end

  # loads data to array of hashes
  def to_table
    result = []
    # load data
    ACSV::CSV.foreach(@file_name, headers: true, skip_blanks: true) do |row|
      row_hash = row.to_hash.delete_if { |key, value| key.blank? || value.blank? }
      next if row_hash.empty?
      result.push(row_hash)
    end
    result.compact
  end
end