# lib/tasks/extract_table_rows_to_fixture.rake
#
# Walter McGinnis, 2007-07-04
#
# $ID: $
namespace :db do
  desc 'Create YAML fixture from data in an existing database table and specific rows.
  set table with TABLE=\'table_name\' set rows with
  with ROWS as comma separated value in quotes.
  Default output to test/fixtures, but you can specify another location by
  setting OUTPUT_FIXTURES_TO_PATH (no trailing /).

  Defaults to development database.  Set RAILS_ENV to override.'

  # modified to dump to either db/bootstrap or test/fixtures
  task :extract_table_rows_to_fixture => :environment do
    table_name = ENV['TABLE']
    sql  = "SELECT * FROM #{table_name} where id in (#{ENV['ROWS']})"
    ActiveRecord::Base.establish_connection
    i = "000"
    base_path = ENV['OUTPUT_FIXTURES_TO_PATH']
    if base_path.blank?
      base_path = "#{RAILS_ROOT}/test/fixtures"
    end
    File.open("#{base_path}/#{table_name}.yml", 'w') do |file|
      data = ActiveRecord::Base.connection.select_all(sql % table_name)
      file.write data.inject({}) { |hash, record|
        hash["#{table_name}_#{i.succ!}"] = record
        hash
      }.to_yaml
    end
  end
end