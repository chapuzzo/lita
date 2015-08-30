require "i18n"

require_relative "configurable"
require_relative "namespace"

module Lita
  # Adapters are the glue between Lita's API and a chat service.
  class Adapter
    # The names of methods that should be implemented by an adapter.
    # @since 4.4.0
    REQUIRED_METHODS = %i(
      chat_service
      join
      part
      roster
      run
      send_messages
      set_topic
      shut_down
    ).freeze

    extend Namespace
    extend Configurable

    # The instance of {Lita::Robot}.
    # @return [Lita::Robot]
    attr_reader :robot

    class << self
      # Returns the translation for a key, automatically namespaced to the adapter.
      # @param key [String] The key of the translation.
      # @param hash [Hash] An optional hash of values to be interpolated in the string.
      # @return [String] The translated string.
      def translate(key, hash = {})
        I18n.translate("lita.adapters.#{namespace}.#{key}", hash)
      end

      alias_method :t, :translate
    end

    # @param robot [Lita::Robot] The currently running robot.
    def initialize(robot)
      @robot = robot
    end

    # The adapter's configuration object.
    # @return [Lita::Configuration] The adapter's configuration object.
    # @since 4.0.0
    def config
      robot.config.adapters.public_send(self.class.namespace)
    end

    # @!method chat_service
    # May return an object exposing chat-service-specific APIs.
    # @return [Object, nil] The chat service API object, if any.
    # @abstract This should be implemented by the adapter.
    # @since 4.6.0

    # @!method join(room_id)
    # Joins the room with the specified ID.
    # @param room_id [String] The ID of the room.
    # @return [void]
    # @abstract This should be implemented by the adapter.
    # @since 3.0.0

    # @!method part(room_id)
    # Parts from the room with the specified ID.
    # @param room_id [String] The ID of the room.
    # @return [void]
    # @abstract This should be implemented by the adapter.
    # @since 3.0.0

    # @!method roster(room)
    # Get a list of users that are online in the given room.
    # @param room [Lita::Room] The room to return a roster for.
    # @return [Array<Lita::User>] An array of users.
    # @abstract This should be implemented by the adapter.
    # @since 4.4.0

    # @!method run
    # The main loop. Should connect to the chat service, listen for incoming
    # messages, create {Lita::Message} objects from them, and dispatch them to
    # the robot by calling {Lita::Robot#receive}.
    # @return [void]
    # @abstract This should be implemented by the adapter.

    # @!method send_messages(target, strings)
    # Sends one or more messages to a user or room.
    # @param target [Lita::Source] The user or room to send messages to.
    # @param strings [Array<String>] An array of messages to send.
    # @return [void]
    # @abstract This should be implemented by the adapter.

    # @!method set_topic(target, topic)
    # Sets the topic for a room.
    # @param target [Lita::Source] The room to change the topic for.
    # @param topic [String] The new topic.
    # @return [void]
    # @abstract This should be implemented by the adapter.

    # @!method shut_down
    # Performs any clean up necessary when disconnecting from the chat service.
    # @return [void]
    # @abstract This should be implemented by the adapter.
    REQUIRED_METHODS.each do |method|
      define_method(method) do |*_args|
        Lita.logger.warn(I18n.t("lita.adapter.method_not_implemented", method: method))
      end
    end

    # The Lita logger.
    # @return [Lita::Logger] The Lita logger.
    # @since 4.0.2
    def log
      Lita.logger
    end

    # Formats a name for "mentioning" a user in a group chat. Override this
    # method in child classes to customize the mention format for the chat
    # service.
    # @param name [String] The name to format as a mention name.
    # @return [String] The formatted mention name.
    # @since 3.1.0
    def mention_format(name)
      "#{name}:"
    end

    # @see .translate
    def translate(*args)
      self.class.translate(*args)
    end

    alias_method :t, :translate
  end
end
