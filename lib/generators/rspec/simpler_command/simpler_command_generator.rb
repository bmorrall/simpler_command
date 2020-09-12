# frozen_string_literal: true

require "generators/rspec"

module Rspec
  module Generators
    # Rspec SimplerCommand Generator.
    #
    # Generates a spec for a command using SimplerCommand.
    #
    # Provide arguments to assist with boilerplate generation of your commands.
    #
    # == Examples
    #
    #    rails generator rspec:simpler_command EnableMaintainance
    #    # => spec/commands/enable_maintainance_spec.rb
    #    rails generator rspec:simpler_command PublishArticle article
    #    # => spec/commands/publish_article_spec.rb
    class SimplerCommand < Base
      source_root File.expand_path("templates", __dir__)

      argument :arguments, type: :array, default: [], banner: "command arguments"

      def add_command_spec
        template "command_spec.rb.erb", "spec/commands/#{file_name}_spec.rb"
      end

      private

      def argument_parameters
        arguments.map(&:parameterize)
      end

      def method_call(call_name, parameters)
        [
          call_name,
          parameters.any? ? "(" : "",
          parameters.join(", "),
          parameters.any? ? ")" : ""
        ].join
      end
    end
  end
end
