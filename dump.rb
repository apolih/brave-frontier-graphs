require 'openssl'
require 'net/http'
require 'open3'
require 'cgi'

TABLE_URL = 'https://www.googleapis.com/fusiontables/v2/query'
PROJECT_KEY = 'AIzaSyCyF9yZ9Lyl57HAQXtzrd3yONewk4-fGSg'
TABLE_KEY = '1n7DYUrmCNBoU-MDUnnU2JV2NDpAdIogQ3LbK48Yx'
REFERER = "http://touchandswipe.github.io/bravefrontier/unitsguide" 
DATA_DIR = "#{ENV['HOME']}/repo/apolih/brave-frontier-graphs/data"
HTTP_PORT = 80
HTTPS_PORT = 443

# @todo
def query
  sql = "select * form #{TABLE_KEY}"
  query = [
    "key=#{PROJECT_KEY}",
    "sql=#{CGI.escape(sql)}"
  ]
end

# Make a get request at the URL; it is implied that the URL refers to 
# @SamGreenPuck Google fusiontable documented at http://bravefrontierpros.tumblr.com/
# which by implication requires the referer HTTP header to be set in a certain way
def get(url)
  uri = URI.parse(url)
  response = nil
  opt = {:use_ssl => true}
  #start(address, port=nil, p_addr=nil, p_port=nil, p_user=nil, p_pass=nil, opt, &block)
  Net::HTTP.start(uri.host, uri.port, p_addr=nil, p_port=nil, p_user=nil, p_pass=nil, opt) { |http|
    request = Net::HTTP::Get.new uri
    request['Referer'] = REFERER
    response = http.request request # Net::HTTPResponse object
  }
  return response
end

# Download copy of units database as of the current time
# @param [String] data_path the path to save the file at
# @return [Fixnum] file size of written file
def dump(data_path=File.join(DATA_DIR, "#{Time.now.to_i}.json"))

  if(File.exists?(data_path))
    raise ArgumentError.new("Refusing to overwrite existing file #{data_path}")
  else
    dir, base = File.split(data_path)
    cmd = "mkdir -p #{dir}"
    pid = status = stderr = nil
    #Open3.popen3([env,] cmd... [, opts]) {|stdin, stdout, stderr, wait_thr|
    Open3.popen3(cmd) {|stdin, stdout, stderr, wait_thr|
      pid = wait_thr.pid # pid of the started process.
      status = wait_thr.value # Process::Status object returned.
    }
    if(status.success?)
    else
      raise ArgumentError.new("Could not create directory #{dir}; stderr of #{cmd} : #{stderr}")
    end
  end

  sql = "select * from #{TABLE_KEY}"
  query = [
    "key=#{PROJECT_KEY}",
    "sql=#{CGI.escape(sql)}"
  ]
  url = "#{TABLE_URL}?#{query.join("&")}"
  response = get(url)
  
  File.open(data_path, "w"){|ff|
    size = ff.write(response.body)
  }
end

# test/script section
if $0 == __FILE__
  dump()
end
