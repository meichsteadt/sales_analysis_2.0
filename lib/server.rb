require 'uri'
require 'net/http'
class Server
  attr_accessor :php_id, :ul, :jses_id, :user_name, :password
  def initialize(user_id, user_name, password)
    @user_id = user_id
    @user_name = user_name
    @password = password
    @php_id = login
    @ul = get_unique_login
    @jses_id = get_jsess
  end

  def login
    url = URI("https://erp.homelegance.com/index.php")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW'
    request["cache-control"] = 'no-cache'
    request["Postman-Token"] = '8f011755-de1c-48b9-816e-40da2ff2c35c'
    request.body = "------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"uname\"\r\n\r\n#{@user_name}\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"psw\"\r\n\r\n#{@password}\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"_operate\"\r\n\r\nlogin\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"tmp\"\r\n\r\n0.8448342778550284\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--"

    response = http.request(request)
    puts response.read_body
    response.get_fields('set-cookie')[0].split(";")[0].delete("PHPSESSID=")
      # @php_id = res.cookies["PHPSESSID"]
      # @php_cookie = res.cookie_jar.store.find("@jar").first
  end

  def get_jsess
    url = URI("https://erp.homelegance.com/j/s/salesAnalysis?unique_login_check_id_xx=#{@ul}&php=1")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    response.get_fields('set-cookie')[0].split(" ")[0].split("=")[-1]
  end

  def get_unique_login
    url = URI("https://erp.homelegance.com/index.php?_action=inventory&_operate=sales_analysis")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "PHPSESSID=#{@php_id}; uname=null; psw=null; remember=null"
    request["Upgrade-Insecure-Requests"] = '1'
    request["Referer"] = 'https://erp.homelegance.com/index.php?_operate=welcome&_method=left'
    request["Accept"] = 'application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3'
    request["Accept-Encoding"] = 'gzip, deflate, br'
    request["User-Agent"] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36'
    request["Content-Type"] = 'application/x-www-form-urlencoded'
    request["Connection"] = 'keep-alive'
    request["Accept-Language"] = 'en-US,en;q=0.9,pt;q=0.8'
    request["cache-control"] = 'no-cache'

    response = http.request(request)
    response.get_fields('location')[0].split("unique_login_check_id_xx=")[-1].split("&")[0]

  end


  def get_sales_numbers
    begin_date = Date.today.beginning_of_month.strftime('%Y-%m-%d')
    end_date = Date.today.strftime('%Y-%m-%d')
    url = URI("https://erp.homelegance.com/j/s/salesAnalysis/salesAnalysisData?salesAnalysisFormat=salesAnalysis_detail_customer&location=all&modelId=-1&analysisBy=customer&orderBy=default&channel=&beginDate=#{begin_date}&endDate=#{end_date}&salesman=&customer=&clasz=&shipper=&admin=&isDropShip=&invoiceStatus=YES&contactType=&group_name_ids=&state=&loginUser=#{@ul}&searchLeval=detail&tJson={%22Subject_to_Commission%22:%22Y%22,%22Catalog_Type%22:%22%22,%22simple%22:%22%22,%22is_ar%22:%22true%22,%22status%22:%2214%22,%22php%22:%221%22,%22table_time%22:%221555361952135%22,%22format%22:%22salesAnalysis_detail_customer%22}&_search=false&nd=1555363148632&rows=20000&page=1&sidx=so_id&sord=asc")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Cookie"] = 'JSESSIONID=' + @jses_id

    response = http.request(request)
    JSON.parse(response.read_body)["items"].select{|e| e["country"] != "Customer Group Sum" && e["country"] != " Price Group Sum"}
  end

  def upload_from_json
    Upload.upload_from_json(@user_id, self.get_sales_numbers)
  end
end
