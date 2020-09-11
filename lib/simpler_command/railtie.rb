# frozen_string_literal: true

module SimplerCommand
  # SimplerCommand Railtie.
  class Railtie < ::Rails::Railtie
    generators do
      require "generators/simpler_command/simpler_command_generator"
    end
  end
end
