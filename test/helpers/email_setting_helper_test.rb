require 'test/unit'

class EmailSettingHelperTest < Test::Unit::TestCase

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

  test "get email setting YAML file path" do
    assert_equal File.join(Rails.root, "config", "smtp.yml"), EmailSettingHelper.get_email_setting_file_path
  end
end