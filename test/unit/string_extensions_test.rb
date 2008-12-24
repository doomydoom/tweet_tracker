require 'test_helper'

class StringExtensionsTest < Test::Unit::TestCase
  should "Clean the string by stripping whitespace, removing whitespace in the string, and downcasing it" do
    test_string = " Some Thing Here "
    assert_equal("somethinghere", test_string.clean)
  end
end