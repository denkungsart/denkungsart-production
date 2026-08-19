require "test_helper"

class BasicAuthInitializerTest < Minitest::Test
  MiddlewareConfig = Struct.new(:entries) do
    def use(middleware)
      entries << middleware
    end
  end

  def setup
    @original_user = Denkungsart::Production.basic_auth_user
    @original_password = Denkungsart::Production.basic_auth_password
  end

  def teardown
    Denkungsart::Production.basic_auth_user = @original_user
    Denkungsart::Production.basic_auth_password = @original_password
  end

  def test_adds_middleware_when_both_credentials_are_configured
    Denkungsart::Production.basic_auth_credentials = ["alice", "secret"]
    middleware = run_initializer

    assert_equal [Denkungsart::Production::BasicAuth], middleware.entries
  end

  def test_does_not_add_middleware_when_a_credential_is_missing
    Denkungsart::Production.basic_auth_credentials = ["alice", nil]
    assert_empty run_initializer.entries

    Denkungsart::Production.basic_auth_credentials = [nil, "secret"]
    assert_empty run_initializer.entries
  end

  private
    def run_initializer
      middleware = MiddlewareConfig.new([])
      config = Struct.new(:middleware).new(middleware)
      app = Struct.new(:config).new(config)
      initializer = Denkungsart::Production::Engine.initializers.find do |candidate|
        candidate.name == "denkungsart-production.basic_auth"
      end

      initializer.run(app)
      middleware
    end
end
