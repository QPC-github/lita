module Lita
  # An object to hold various types of data including configuration and plugins.
  class Registry
    # Allows a registry to be added to another object.
    module Mixins
      # The primary configuration object. Provides user settings for the robot.
      # @return [Object] The configuration object.
      def config
        @config ||= DefaultConfiguration.new(self).finalize
      end

      # Yields the configuration object. Called by the user in a +lita_config.rb+ file.
      # @yieldparam [Object] config The configuration object.
      # @return [void]
      def configure
        yield config
      end

      # A registry of adapters.
      # @return [Hash] A map of adapter keys to adapter classes.
      def adapters
        @adapters ||= {}
      end

      # A registry of handlers.
      # @return [Set] The set of handlers.
      def handlers
        @handlers ||= Set.new
      end

      # A registry of hook handler objects.
      # @return [Hash] A hash mapping hook names to sets of objects that handle them.
      # @since 3.2.0
      def hooks
        @hooks ||= Hash.new { |h, k| h[k] = Set.new }
      end

      # @overload register_adapter(key, adapter)
      #   Adds an adapter to the registry under the provided key.
      #   @param key [String, Symbol] The key that identifies the adapter.
      #   @param adapter [Class] The adapter class.
      #   @return [void]
      # @overload register_adapter(key, &block)
      #   Adds an adapter to the registry under the provided key.
      #   @param key [String, Symbol] The key that identifies the adapter.
      #   @param block [Proc] The body of the adapter class.
      #   @return [void]
      #   @since 4.0.0
      def register_adapter(key, adapter = nil, &block)
        adapter = Builder.new(key, &block).build_adapter if block

        unless adapter.is_a?(Class)
          raise ArgumentError, I18n.t("lita.core.register_adapter.block_or_class_required")
        end

        adapters[key.to_sym] = adapter
      end

      # @overload register_handler(handler)
      #   Adds a handler to the registry.
      #   @param handler [Lita::Handler] The handler class.
      #   @return [void]
      # @overload register_handler(key, &block)
      #   Adds a handler to the registry.
      #   @param key [String] The namespace of the handler.
      #   @param block [Proc] The body of the handler class.
      #   @return [void]
      #   @since 4.0.0
      def register_handler(handler_or_key, &block)
        if block
          handler = Builder.new(handler_or_key, &block).build_handler
        else
          handler = handler_or_key

          unless handler.is_a?(Class)
            raise ArgumentError, I18n.t("lita.core.register_handler.block_or_class_required")
          end
        end

        handlers << handler
      end

      # Adds a hook handler object to the registry for the given hook.
      # @return [void]
      # @since 3.2.0
      def register_hook(name, hook)
        hooks[name.to_s.downcase.strip.to_sym] << hook
      end

      # Clears the configuration object and the adapter, handler, and hook registries.
      # @return [void]
      # @since 3.2.0
      def reset
        reset_adapters
        reset_config
        reset_handlers
        reset_hooks
      end

      # Resets the adapter registry, removing all registered adapters.
      # @return [void]
      # @since 3.2.0
      def reset_adapters
        @adapters = nil
      end

      # Resets the configuration object. The next call to {#config}
      # will create a fresh config object.
      # @return [void]
      def reset_config
        @config = nil
      end
      alias_method :clear_config, :reset_config

      # Resets the handler registry, removing all registered handlers.
      # @return [void]
      # @since 3.2.0
      def reset_handlers
        @handlers = nil
      end

      # Resets the hooks registry, removing all registered hook handlers.
      # @return [void]
      # @since 3.2.0
      def reset_hooks
        @hooks = nil
      end
    end

    include Mixins
  end
end
