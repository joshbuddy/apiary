require 'method_args'
require 'callsite'
require 'http_router'
require 'thin'
require 'rack'
require 'apiary/version'

module Apiary
  ApiMethod = Struct.new(:method, :http_method, :path)
  
  module ClassMethods

    def get(path = nil)
      __set_routing(:get, path)
    end

    def post(path = nil)
      __set_routing(:get, path)
    end

    def put(path = nil)
      __set_routing(:put, path)
    end

    def delete(path = nil)
      __set_routing(:put, path)
    end

    def version(number)
      @version = number
    end

    def __set_routing(method, path)
      @http_method, @path = method, path
    end

    def method_added(m)
      if @http_method
        MethodArgs.register(Callsite.parse(caller.first).filename)
        @cmds ||= []
        @cmds << ApiMethod.new(m, @http_method, @path)
        @http_method = nil
        @path = nil
      end
    end

    def default_path(m)
      instance_method(m).args.inject(m.to_s) do |path, arg|
        path << case arg.type
        when :required then "/:#{arg.name}"
        when :optional then "/(:#{arg.name})"
        when :splat    then "/*#{arg.name}"
        end
      end
    end

    def __as_app(&blk)
      router = HttpRouter.new
      @cmds.each do |cmd|
        path = "#{@version}/#{cmd.path || default_path(cmd.method)}".squeeze('/')
        route = router.add(path)
        route.send(cmd.http_method) if cmd.http_method
        route.to { |env| 
          Rack::Response.new((blk ? blk.call : new).send(cmd.method, *env['router.response'].param_values).to_s).finish
        }
      end
      router
    end

    def run(port = 3000, &blk)
      api = self
      raise "No version specified" unless @version
      Thin::Server.new('0.0.0.0', port) {
        run api.__as_app(&blk)
      }.start
    end
  end

  def self.included(cls)
    cls.instance_eval "class << self; include ClassMethods; end"
  end
end
