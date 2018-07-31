require 'test_helper'

class EmailSettingControllerTest < ActionDispatch::IntegrationTest
  test "get email setting" do
    get "/email_setting/get_setting"
    assert_not_empty response.body
    assert_equal 200, status
  end

  test "update email setting" do
    test_address = "#{srand}_test_address"
    post "/email_setting/update_setting", params: {options: {address: test_address}}
    assert_equal 200, status

    setting = EmailSettingHelper.get_email_setting('test')
    assert_equal test_address, setting['address']
  end
end
