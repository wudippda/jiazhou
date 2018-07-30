require 'test/unit'

  class UserEmailTest < Test::Unit::TestCase

    # Called before every test method runs. Can be used
    # to set up fixture information.
    def setup
      # Do nothing
    end

    # Called after every test method runs. Can be used to tear
    # down fixture information.

    def teardown
      # Do nothing
    end

    test "test send a simple email" do
      #UserMailer.with(User.new(id: 1, email: "francis.zhong@sap.com")).incoming_email
    end
  end