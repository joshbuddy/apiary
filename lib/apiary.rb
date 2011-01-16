require 'method_args'
require 'callsite'
require 'http_router'
require 'thin'
require 'rack'

module Apiary
  ApiMethod = Struct.new(:method, :http_method, :path)
  
  module ClassMethods

    def get(path = nil)
      __set_routing(:get, path)
    end

    def post(path = nil)
      __set_routing(:get, path)
    end

    def version(number)
      @version = number
    end

    def __set_routing(method, path)
      @method, @path = method, path
    end

    def method_added(m)
      MethodArgs.register(Callsite.parse(caller.first).filename)
      @cmds ||= []
      @cmds << ApiMethod.new(m, @http_method, @path)
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

    def run(port = 3000, &blk)
      raise "No version specified" unless @version
      router = HttpRouter.new
      @cmds.each do |cmd|
        path = "#{@version}/#{cmd.path || default_path(cmd.method)}".squeeze('/')
        route = router.add(path)
        route.send(cmd.http_method) if cmd.http_method
        route.to { |env| 
          Rack::Response.new((blk ? blk.call : new).send(cmd.method, *env['router.response'].param_values).to_s).finish
        }
      end
      Thin::Server.new('0.0.0.0', port) {
        run router
      }.start
    end
  end

  def self.included(cls)
    cls.instance_eval "class << self; include ClassMethods; end"
  end
end
