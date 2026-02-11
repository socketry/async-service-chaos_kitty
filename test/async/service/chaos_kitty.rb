# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/chaos_kitty"

describe Async::Service::ChaosKitty do
	it "has a version" do
		expect(Async::Service::ChaosKitty::VERSION).to be_a(String)
	end
	
	it "can create an endpoint" do
		endpoint = Async::Service::ChaosKitty.endpoint("test-chaos.ipc")
		expect(endpoint).to be_a(IO::Endpoint::Generic)
	ensure
		File.unlink("test-chaos.ipc") if File.exist?("test-chaos.ipc")
	end
end
