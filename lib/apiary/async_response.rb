require 'thin/async'

module Apiary
  class AsyncResponse < Thin::AsyncResponse
    def end(out = nil)
      self.<<(out) if out
      done
    end
  end
end