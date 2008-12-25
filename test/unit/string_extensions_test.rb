require 'test_helper'

class StringExtensionsTest < Test::Unit::TestCase
  def test_should_clean_the_string
    test_string = " Some Thing Here "
    assert_equal("somethinghere", test_string.clean)
  end
end