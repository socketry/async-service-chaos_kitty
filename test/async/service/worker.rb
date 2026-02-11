# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/chaos_kitty"

describe Async::Service::ChaosKitty::Worker do
	let(:endpoint) {Async::Service::ChaosKitty.endpoint("test-chaos-worker.ipc")}
	
	it "can create a worker" do
		worker = Async::Service::ChaosKitty::Worker.new(endpoint: endpoint)
		expect(worker).to be_a(Async::Service::ChaosKitty::Worker)
	ensure
		File.unlink("test-chaos-worker.ipc") if File.exist?("test-chaos-worker.ipc")
	end
	
	it "can create a worker with process ID" do
		worker = Async::Service::ChaosKitty::Worker.new(
			process_id: Process.pid,
			endpoint: endpoint
		)
		
		expect(worker.process_id).to be == Process.pid
	ensure
		File.unlink("test-chaos-worker.ipc") if File.exist?("test-chaos-worker.ipc")
	end
end
