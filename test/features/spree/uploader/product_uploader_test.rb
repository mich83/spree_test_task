require 'test_helper'
require 'uploader_test_helper'

class Spree::Uploader::ProductUploaderTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  TITLES = %W[name description price availability_date slug stock_total category]
  CORRECT_VALUES =['Ruby on Rails Bag', 'Animi officia aut amet molestiae atque excepturi. Placeat est cum occaecati molestiae quia. Ut soluta ipsum doloremque perferendis eligendi voluptas voluptatum.','22,99','2017-12-04T14:55:22.913Z','ruby-on-rails-bag','15','Bags']
  INCORRECT_VALUES = [nil, nil,'22,ww99','201dd7-12-0ww4T14:55:22.913Z',nil,'15ww',nil]
  SHOULD_FAIL_WHEN_NO_COLUMN = [true, false, true, false, false, false, false]
  SHOULD_FAIL_WHEN_INVALID = [false, false, true, false, false, false, false]


  def build_uploader(rows)
    csv = Spree::Uploader::UploaderTestHelper.new
    rows.each do |row|
      csv.row(row)
    end
    assert_performed_jobs 0
    uploader = nil
    perform_enqueued_jobs do
      uploader = csv.to_file_upload
    end
    assert_performed_jobs 1
    uploader.reload
  end

  def should_fail(uploader)
    assert_not_nil uploader.error_messages_text
    assert_not uploader.success
  end

  def should_success(uploader)
    assert_nil uploader.error_messages_text
    assert uploader.success
  end

  def titles_and_values(options = {})
    current_titles = TITLES.dup
    current_values = CORRECT_VALUES.dup
    current_values[4] = Random.rand(10000).to_s
    if options[:incorrect]
      current_values[options[:incorrect]] = INCORRECT_VALUES[options[:incorrect]]
    end
    if options[:remove]
      current_titles.delete_at(options[:remove])
      current_values.delete_at(options[:remove])
    end
    [current_titles, current_values]
  end

  def run_with_options(column_should_fail, options)
    uploader = build_uploader(titles_and_values(options))
    if column_should_fail
      should_fail uploader
    else
      should_success uploader
    end
  end

  Spree::Product.destroy_all

  test 'load valid csv' do
    Spree::Product.destroy_all
    should_success build_uploader(titles_and_values)
  end

  (0..6).each do |col|
    test "when there is no column #{TITLES[col]} then upload should #{SHOULD_FAIL_WHEN_NO_COLUMN[col] ? 'fail' : 'success'}" do
      run_with_options(SHOULD_FAIL_WHEN_NO_COLUMN[col], remove: col)
    end
    if INCORRECT_VALUES[col]
      test "whem column #{TITLES[col]} is invalid then upload should #{SHOULD_FAIL_WHEN_INVALID[col] ? 'fail' : 'success'}" do
        run_with_options(SHOULD_FAIL_WHEN_INVALID[col], incorrect: col)
      end
    end
  end
end