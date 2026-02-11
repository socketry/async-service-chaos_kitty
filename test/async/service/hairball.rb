# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/chaos_kitty"

describe Async::Service::ChaosKitty::Hairball do
	it "can create a hairball chaos operation" do
		hairball = Async::Service::ChaosKitty::Hairball.new
		expect(hairball).to be_a(Async::Service::ChaosKitty::Hairball)
	end
	
	it "can configure hairball parameters" do
		hairball = Async::Service::ChaosKitty::Hairball.new(
			interval: 20,
			probability: 0.5,
			min_delay: 1.0,
			max_delay: 10.0
		)
		
		status = hairball.status
		expect(status[:hairball][:probability]).to be == 0.5
		expect(status[:hairball][:delay_range]).to be == [1.0, 10.0]
	end
end
