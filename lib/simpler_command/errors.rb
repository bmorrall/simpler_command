# frozen_string_literal: true

module SimplerCommand
  # Provides an Errors implementation similar to ActiveModel::Errors
  class Errors < Hash
    def add(key, value, _opts = {})
      self[key] ||= []
      self[key] << value
      self[key].uniq!
    end

    def add_all(errors_hash)
      errors_hash.each do |key, values|
        Array(values).each do |value|
          add key, value
        end
      end
    end

    def each
      each_key do |field|
        self[field].each { |message| yield field, message }
      end
    end

    def full_messages
      map { |attribute, message| full_message(attribute, message) }
    end

    # Allow ActiveSupport to render errors similar to ActiveModel::Errors
    def as_json(options = nil)
      {}.tap do |output|
        each do |field, value|
          output[field] ||= []
          output[field] << value
        end
      end.as_json(options)
    end

    private

    def full_message(attribute, message)
      return message if attribute == :base

      attr_name = StringUtils.humanize(attribute.to_s)
      [attr_name, message].join(" ")
    end
  end
end
