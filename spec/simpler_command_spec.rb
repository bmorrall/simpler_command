# frozen_string_literal: true

RSpec.describe SimplerCommand do
  class SuccessfulCommand
    prepend SimplerCommand

    def initialize(number_a, number_b)
      @number_a = number_a
      @number_b = number_b
    end

    def call
      @number_a + @number_b
    end
  end

  class TouchyCommand
    prepend SimplerCommand

    def initialize(object)
      @object = object
    end

    def call
      @object.touch
    end
  end

  class FailingCommand
    prepend SimplerCommand

    def call
      errors.add(:base, "Failed as expected")
    end
  end

  class IncompleteCommand
    prepend SimplerCommand

    # Note: #call has not been implemented
  end

  it "has a version number" do
    expect(SimplerCommand::VERSION).not_to be nil
  end

  describe ".call" do
    context "with a successful command" do
      it "returns a response object with the result", :aggregate_failures do
        success_command = SuccessfulCommand.call(2, 3)
        expect(success_command).to be_success
        expect(success_command).to be_successful
        expect(success_command.result).to eq 5

        expect(success_command).not_to be_failure
      end

      it "calls a provided block with the result", :aggregate_failures do
        yielded_result = nil
        SuccessfulCommand.call(1, 3) do |res|
          yielded_result = res
        end
        expect(yielded_result).to be 4
      end
    end

    context "with a failing command" do
      it "returns a response object", :aggregate_failures do
        failed_command = FailingCommand.call
        expect(failed_command).to be_failure

        expect(failed_command).not_to be_success
        expect(failed_command).not_to be_successful

        expect(failed_command.errors[:base]).to eq ["Failed as expected"]

        expect do
          failed_command.result
        end.to raise_error(SimplerCommand::Failure, "Failed as expected")
      end

      it "throws a SimplerCommand::Failure when invoked with a block" do
        expect do
          FailingCommand.call do |_result|
            raise "block was unexpectedly called"
          end
        end.to raise_error(SimplerCommand::Failure, "Failed as expected")
      end
    end

    context "with a failing command using ActiveModel::Validations", :as_only do
      class FailingValidationCommand
        prepend SimplerCommand

        def call
          errors.add(:base, "All is Broken")
          errors.add(:foo, "is not welcome")
        end
      end

      before(as_only: true) do
        FailingValidationCommand.include ActiveModel::Validations
      end

      it "returns a response object", :aggregate_failures do
        failed_command = FailingValidationCommand.call
        expect(failed_command).to be_failure

        expect(failed_command).not_to be_success
        expect(failed_command).not_to be_successful

        expect(failed_command.errors[:base]).to eq ["All is Broken"]
        expect(failed_command.errors[:foo]).to eq ["is not welcome"]

        expect do
          failed_command.result
        end.to raise_error(SimplerCommand::Failure, "All is Broken and Foo is not welcome")
      end
    end

    context "with an incomplete command" do
      it "raises a SimplerCommand::NotImplementedError" do
        expect do
          IncompleteCommand.call
        end.to raise_error(SimplerCommand::NotImplementedError)
      end
    end
  end

  describe ".call!" do
    context "with a successful command" do
      it "returns the result" do
        result = SuccessfulCommand.call!(2, 3)
        expect(result).to eq 5
      end
    end

    context "with a failing command" do
      it "throws an SimplerCommand::Failure" do
        expect do
          FailingCommand.call!
        end.to raise_error(SimplerCommand::Failure, "Failed as expected")
      end
    end
  end

  describe "#call" do
    it "returns a response object with the result", :aggregate_failures do
      success_command = SuccessfulCommand.new(2, 3)
      success_command.call

      expect(success_command).to be_success
      expect(success_command).to be_successful
      expect(success_command.result).to eq 5

      expect(success_command).not_to be_failure
    end

    it "only invokes the #call function once" do
      object = double(touch: true)

      command = TouchyCommand.new(object)
      command.call
      command.call
      command.call

      expect(command.result).to eq true

      expect(object).to have_received(:touch).once
    end
  end
end
