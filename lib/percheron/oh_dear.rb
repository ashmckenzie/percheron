module Percheron
  class OhDear

    def initialize(exception)
      @exception = exception
    end

    def generate
      <<-EOS

OH DEAR, we are terribly sorry.. something unexpected occurred :(

--snip--

Info
----
Ruby: #{RUBY_VERSION}
Percheron: #{Percheron::VERSION}

Trace
-----
#{exception_message}

#{exception_backtrace}

--snip--

Please copy the detail between the --snip--'s above and raise a ticket - https://github.com/ashmckenzie/percheron/issues/new?labels=bug

      EOS
    end

    private

      attr_reader :exception

      def exception_message
        exception.inspect
      end

      def exception_backtrace
        exception.backtrace ? exception.backtrace.join("\n") : ''
      end

  end
end
