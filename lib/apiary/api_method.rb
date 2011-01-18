module Apiary
  class ApiMethod < Struct.new(:method, :http_method, :path, :async)
    alias_method :async?, :async
  end
end
