# frozen_string_literal: true

module SimplerCommand
  # Simple Utilities for either using ActiveSupport methods, or falling back to equivalents.
  #
  # Used only for generating Human-readable Strings, which should not be used for logic
  module StringUtils
    module_function

    # Converts a string to a human-readable string
    def humanize(string)
      attribute = string.tr(".", "_")
      if attribute.respond_to?(:humanize)
        attribute.humanize
      else
        attribute.tr("_", " ").capitalize
      end
    end

    # Attempt Array#to_sentence provided by ActiveSupport, or fall back to join
    def to_sentence(array)
      if array.respond_to?(:to_sentence)
        array.to_sentence
      else
        array.join(", ")
      end
    end
  end
end
