class BasicAsync
  include Apiary

  version '1.0'

  def initialize(var = nil)
    @var = var
  end

  aget
  def ping
    EM.add_timer(0.1) do
      async_response.end 'ping'
    end
  end

  aget
  def var
    async_response.end @var
  end
end
