require "test_helper"
require "rack/mock"
require "base64"

class BasicAuthTest < Minitest::Test
  def setup
    @original_user = Denkungsart::Production.basic_auth_user
    @original_password = Denkungsart::Production.basic_auth_password
    @original_excluded_paths = Denkungsart::Production.basic_auth_excluded_paths

    Denkungsart::Production.basic_auth_credentials = ["alice", "secret"]
    Denkungsart::Production.basic_auth_excluded_paths = ["/up"]
  end

  def teardown
    Denkungsart::Production.basic_auth_user = @original_user
    Denkungsart::Production.basic_auth_password = @original_password
    Denkungsart::Production.basic_auth_excluded_paths = @original_excluded_paths
  end

  def test_rejects_missing_or_incorrect_credentials
    assert_equal 401, get("/").status
    assert_equal 401, get("/", ["alice", "wrong"]).status
    assert_equal 401, get("/", ["wrong", "secret"]).status
  end

  def test_accepts_the_configured_credentials
    response = get("/", ["alice", "secret"])

    assert_equal 200, response.status
    assert_equal "authenticated", response.body
  end

  def test_bypasses_authentication_only_for_exactly_excluded_paths
    assert_equal 200, get("/up").status
    assert_equal 401, get("/up/").status
  end

  private
    def get(path, credentials = nil)
      env = {}
      if credentials
        encoded_credentials = Base64.strict_encode64(credentials.join(":"))
        env["HTTP_AUTHORIZATION"] = "Basic #{encoded_credentials}"
      end

      Rack::MockRequest.new(middleware).get(path, env)
    end

    def middleware
      app = lambda do |_env|
        [200, { "content-type" => "text/plain" }, ["authenticated"]]
      end
      Denkungsart::Production::BasicAuth.new(app)
    end
end
