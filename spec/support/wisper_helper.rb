RSpec.configure do |config|
  config.around(:each) do |example|
    # Clear all global Wisper subscriptions for test isolation
    Wisper.clear if defined?(Wisper)
    example.run
  end
end
