class Basic
  include Apiary

  version '1.0'

  def initialize(var = nil)
    @var = var
  end

  get
  def ping
    'ping'
  end

  get
  def var
    @var
  end
end
