# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/chaos_kitty"

describe Async::Service::ChaosKitty::Server do
	let(:endpoint) {Async::Service::ChaosKitty.endpoint("test-chaos-server.ipc")}
	
	it "can create a server" do
		server = Async::Service::ChaosKitty::Server.new(endpoint: endpoint)
		expect(server).to be_a(Async::Service::ChaosKitty::Server)
	ensure
		File.unlink("test-chaos-server.ipc") if File.exist?("test-chaos-server.ipc")
	end
	
	it "can create a server with chaos operations" do
		hairball = Async::Service::ChaosKitty::Hairball.new
		scratch = Async::Service::ChaosKitty::Scratch.new
		
		server = Async::Service::ChaosKitty::Server.new(
			chaos_operations: [hairball, scratch],
			endpoint: endpoint
		)
		
		expect(server.chaos_operations).to be == [hairball, scratch]
	ensure
		File.unlink("test-chaos-server.ipc") if File.exist?("test-chaos-server.ipc")
	end
end
