# frozen_string_literal: true

# SimplerCommand Generator.
#
# Generates a command using SimplerCommand.
#
# Provide arguments to assist with boilerplate generation of your commands.
#
# == Examples
#
#    rails generator simpler_command EnableMaintainance # => app/commands/enable_maintainance.rb
#    rails generator simpler_command PublishArticle article # => app/commands/publish_article.rb
class SimplerCommandGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  argument :arguments, type: :array, default: [], banner: "command arguments"

  def add_command_template
    template "command.rb.erb", "app/commands/#{file_name}.rb"
  end

  private

  def argument_parameters
    arguments.map(&:parameterize)
  end

  def method_call(call_name, parameters)
    parameters ||= []
    [call_name, parameters.any? ? "(" : "", parameters.join(", "), parameters.any? ? ")" : ""].join
  end
end
