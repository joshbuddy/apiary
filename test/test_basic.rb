class TestBasic < MiniTest::Unit::TestCase
  def test_simple
    run_with(Basic) do
      request('/1.0/ping') do |http|
        assert_equal 200, http.response_header.status
        assert_equal 'ping', http.response
        done
      end
    end
  end

  def test_not_found
    run_with(Basic) do
      request('/1.0/something_else') do |http|
        assert_equal 404, http.response_header.status
        done
      end
    end
  end

  def test_custom_initializer
    run_with(Basic, proc{ Basic.new('hi there')}) do
      request('/1.0/var') do |http|
        assert_equal 200, http.response_header.status
        assert_equal 'hi there', http.response
        done
      end
    end
  end
end
