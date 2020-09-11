# frozen_string_literal: true

require "simpler_command/version"
require "simpler_command/string_utils"
require "simpler_command/errors"

require "simpler_command/railtie" if defined? Rails::Railtie

# Provides a simple structure for Commands (Services).
#
# Prepend SimplerCommand to your Command (Service) objects and implemente a call methods.
#
# In the advent of a failure, Log any errors to an errors object.
module SimplerCommand
  # Indicates the implementing class has not defined a #call method
  class NotImplementedError < StandardError; end

  # Indicates the #call function did not succeed
  class Failure < StandardError; end

  # Provided class methods to each implementing class
  module ClassMethods
    def call(*args, &block)
      new(*args).call(&block)
    end

    def call!(*args)
      call(*args).result
    end
  end

  def self.prepended(base)
    base.extend ClassMethods
  end

  def call(&block)
    raise NotImplementedError unless defined?(super)

    unless called?
      @called = true
      @result = super
    end

    yield result if block_given?

    self
  end

  def success?
    called? && !failure?
  end
  alias successful? success?

  def result
    raise Failure, StringUtils.to_sentence(errors.full_messages) if failure?

    @result
  end

  def failure?
    called? && errors.any?
  end

  def errors
    return super if defined?(super)

    @errors ||= Errors.new
  end

  private

  def called?
    @called ||= false
  end
end
