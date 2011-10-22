module Capistrano
  module Patch
    module Strategy

      def self.new(strategy, config = {})
        require "capistrano/patch/strategy/#{strategy}"

        strategy_const = strategy.to_s.capitalize.gsub(/_(.)/) { $1.upcase }

        const_get(strategy_const).new(config)

      rescue LoadError
        raise Capistrano::Error, "could not find any strategy named `#{strategy}'"
      end

    end
  end
end
