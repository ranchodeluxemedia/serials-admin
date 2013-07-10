require "test/unit"
require "net/http"
require "uri"

class TestSuite < Test::Unit::TestCase

  def call(u)
    uri = URI.parse(u)
    http=Net::HTTP.new(uri.host, uri.port)
    request=Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    return response.code
  end

  def test_sanity
    assert_equal "301", call("http://google.com")
  end

  def test_rails
   # replace this with localhost:80
   assert_equal "301", call("localhost:3000")    
  end

  def test_solr
    assert_equal "301", call("localhost:8983")
  end
end
