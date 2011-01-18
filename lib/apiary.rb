require 'method_args'
require 'callsite'
require 'http_router'
require 'thin'
require 'rack'
require 'apiary/version'
require 'apiary/api_method'
require 'apiary/async_response'

module Apiary

  attr_accessor :rack_env, :async_response

  module ClassMethods

    [:get, :post, :put, :delete].each do |m|
      class_eval "
      def a#{m}(path=nil)
        __set_routing(:get, path, true)
      end

      def #{m}(path=nil)
        __set_routing(:get, path)
      end
      "
    end

    def version(number)
      @version = number
    end

    def __set_routing(method, path, async = false)
      @http_method, @path, @async = method, path, async
    end

    def method_added(m)
      if @http_method
        MethodArgs.register(Callsite.parse(caller.first).filename)
        @cmds ||= []
        @cmds << ApiMethod.new(m, @http_method, @path, @async)
        @http_method, @path, @async = nil, nil, nil
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
          instance = (blk ? blk.call : new)
          instance.rack_env = env
          response = AsyncResponse.new(env)
          if cmd.async?
            instance.async_response = response
            instance.send(cmd.method, *env['router.response'].param_values)
          else
            EM.defer(proc{
              response.status = 200
              response << instance.send(cmd.method, *env['router.response'].param_values).to_s
            }, proc{
              response.done
            })
          end
          response.finish
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
