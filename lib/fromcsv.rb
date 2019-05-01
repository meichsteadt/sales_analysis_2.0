require 'csv'
class Fromcsv
  attr_reader :csv
  def initialize(attr)
    @csv_string = attr[:csv_string]
    @csv = self.parse_csv
  end

  def sales_month(date)
    match = /#{date.strftime("%m")}\/..\/#{date.year}/
    @csv.select {|e| ["Invoice Date"] =~ match}.map {|e| e["Order Price"].delete("$").delete(",").to_f}.sum
  end

  def parse_csv
    CSV.read(@csv_string, headers: true)
  end
end
