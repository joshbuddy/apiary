# Apiary

Stand up simple APIs for consumption.

## Usage

Apiary let's you use any existing class and turn it into an API. For instance, say you have a class like this.

    class Temperature
      def c2f(val)
        Float(val) * 9 / 5 + 32
      end
    end
    
You can convert this to an API by annotating this class with four lines.

    require 'apiary'

    class Temperature
      include Apiary              # Include Apiary as a module in your class

      version '1.0'               # Specifies a version prefix for your api

      get                         # Marks this method as accessible from GET
      def c2f(val)                # This is now available at /1.0/c2f/:val
        Float(val) * 9 / 5 + 32
      end
    end

Now, your API is complete! You can run this with `Temperature.run`. This will create a server on port 3000. You can hit it with

    curl http://localhost:3000/1.0/c2f/23.45

And you'll get back

    74.21
    
Currently, `get`, `post`, `put` and `delete` are supported. You can also supply a path after any verb to have a custom path. Also, the current Rack env hash is available under `rack_env` if you need to take a look at the current request.