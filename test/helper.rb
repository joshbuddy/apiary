require 'minitest/autorun'
require 'em-http'
require 'test/fixtures/basic'
require 'test/fixtures/basic_async'

class MiniTest::Unit::TestCase
  def run_with(cls, optional_blk = nil, &blk)
    EM.run do
      optional_blk ? cls.run(&optional_blk) : cls.run
      EM.add_timer(0.5) { assert false, "Stopped EM server because you didn't call done, or reach your done"; EM.stop }
      EM.next_tick(&blk)
    end
  end

  def request(path, method = :get, opts = {}, &blk)
    raise "you need to be running inside a request" unless EM.reactor_running?
    http = EventMachine::HttpRequest.new("http://127.0.0.1:3000#{path}").__send__(method, opts)
    http.callback { EM.next_tick { blk.call(http) } }
  end

  def done
    EM.stop
  end
end
