require "test_helper"

class LogragePayloadTest < Minitest::Test
  Request = Struct.new(:session)
  Controller = Struct.new(:request) do
    def current_user
      raise "current_user must not be called"
    end
  end

  def test_logs_the_user_id_stored_in_the_session
    session = { "warden.user.user.key" => [[42], "salt"] }

    assert_equal({ uid: 42 }, custom_payload_for(session))
  end

  def test_logs_guest_without_a_signed_in_user
    assert_equal({ uid: :guest }, custom_payload_for({}))
  end

  private
    def custom_payload_for(session)
      lograge_config = Lograge::OrderedOptions.new
      app = Struct.new(:config).new(Struct.new(:lograge).new(lograge_config))
      initializer = Denkungsart::Production::Engine.initializers.find do |candidate|
        candidate.name == "denkungsart-production.setup-lograge"
      end
      initializer.run(app)

      lograge_config.custom_payload_method.call(Controller.new(Request.new(session)))
    end
end
