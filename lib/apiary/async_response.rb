require 'thin/async'

module Apiary
  class AsyncResponse < Thin::AsyncResponse
    def end(out = nil)
      self.<<(out.to_s) if out
      done
    end
  end
end