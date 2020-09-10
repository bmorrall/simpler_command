# SimplerCommand

Yet another simple and standardized way to build and use Commands (aka Service Objects).

Strongly inspired by [simple_command](https://github.com/nebulab/simple_command).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simpler_command'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install simpler_command

## Usage

Here's a basic example of a Command that updates an Album's description, from data collected from an external API.

```ruby
class UpdateAlbumDescription
  prepend SimplerCommand

  def initialize(album, lastfm_client)
    @album = album
    @lastfm_client = @lastfm_client
  end

  def call
    album_info = @lastfm_client.album.get_info(album: album.name, artist: album.artist_name)
    description = album_info.dig("wiki", "contents")
    if description.blank?
      errors.add(:description, "was not found on Last.fm")
      return
    end

    @album.update(description: description)
    nil
  end
end
```

The Command can be invoked by calling `.call` on the class.

```ruby
class Albums::UpdateDescriptionController < ApplicationController
  def create
    album = Album.find(params[:album_id])
    lastfm_client = Lastfm.new(ENV.fetch("LASTFM_API_KEY"), ENV.fetch("LASTFM_API_SECRET"))

    command = UpdateAlbumDescription.call(album, lastfm_client)
    if command.success?
      flash[:notice] = "Description updated successfully"
      redirect_to album
    else
      flash[:alert] = alert.errors.full_messages.to_sentence
      redirect_to edit_album_path(album)
    end
  end
end
```

### The result object

Commands are Service Objects, built with the intent of following the principles of Command-query separation: every method should either be a command that performs an action, or a query that returns data to the caller, but not both.

Occassionally, there are instances where some data would assist with control flow or for logging. In those cases, the returned object from your call is availale from the `result` method in the returned object.

```ruby
PublishPost = Struct.new(:post) do
  prepend SimplerCommand

  def call
    published_date = Time.zone.now
    unless post.update(published_date: published_date)
      errors.add(:base, "Unable to update the Post")
      errors.add_all(post.errors)
    end
    published_date
  end
end

# ...

post = Post.find(123)
command = PublishPost.call(post)
if command.success?
  logger.info("Post published on: " + command.result.strftime("%Y-%m-%d"))
end
```

Attempting to call the `result` method for a failed command will result in a `SimplerCommand::Failure` being raised.

Additionally, you can invoke the `call` method by passing a block, which will yeild the result for a successful operation, or raise `SimplerCommand::Failure` in the advent of an error.

```ruby
class PublishPostJob < ApplicationJob
  retry_on SimplerCommand::Failure

  def perform(post)
    PublishPost.call(post) do |published_date|
      Rollbar.info("Post published on: " + published_date.strftime("%Y-%m-%d"))
    end
  end
end
```

You can also use the `.call!` method instead of `.call`. If there aren't any errors, it will return the result, otherwise it will raise an exception.

```ruby
published_date = PublishPost.call!
puts "Post published on: " + published_date.strftime("%Y-%m-%d")
```

### Using ActiveModel::Validations with I18n

String translations for errors can be provided by using ActiveModel::Validations within your Command.

```ruby
class ExampleCommand
  prepend SimplerCommand
  include ActiveModel::Validations

  def call
    errors.add(:base, :failure)
    nil
  end
end
```

in your locale file

```yaml
# config/locales/en.yml
en:
  activemodel:
    errors:
      models:
        example_command:
          failure: Everything is wrong!
```

### Testing with RSpec

Make the spec file `spec/commands/authenticate_user_spec.rb` like:

```ruby
describe AuthenticateUser do
  subject(:context) { described_class.call(username, password) }

  describe '.call' do
    context 'when the call is successful' do
      let(:username) { 'correct_user' }
      let(:password) { 'correct_password' }

      it 'succeeds' do
        expect(context).to be_success
      end
    end

    context 'when the call is not successful' do
      let(:username) { 'wrong_user' }
      let(:password) { 'wrong_password' }

      it 'fails' do
        expect(context).to be_failure
      end
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bmorrall/simpler_command.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
