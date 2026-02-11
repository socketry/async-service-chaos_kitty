#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

# This is a simple example of running a chaos server with all chaos operations enabled.

require "async/service/chaos_kitty"
require "console"

# Configure chaos operations
chaos_operations = [
	# Hairball: Random delays
	Async::Service::ChaosKitty::Hairball.new(
		interval: 10,
		probability: 0.5,
		min_delay: 0.5,
		max_delay: 2.0
	),
	
	# Scratch: Process termination (low probability)
	Async::Service::ChaosKitty::Scratch.new(
		interval: 30,
		probability: 0.1,
		signal: :TERM
	),
	
	# Floop: Memory spikes
	Async::Service::ChaosKitty::Floop.new(
		interval: 15,
		probability: 0.3,
		min_size_mb: 10,
		max_size_mb: 50,
		hold_duration: 2
	),
	
	# Zoomies: CPU spikes
	Async::Service::ChaosKitty::Zoomies.new(
		interval: 15,
		probability: 0.3,
		min_duration: 0.5,
		max_duration: 2.0
	),
	
	# Yowl: Random exceptions
	Async::Service::ChaosKitty::Yowl.new(
		interval: 20,
		probability: 0.2
	)
]

Console.logger.info("Starting chaos kitty server...")
Console.logger.info("Chaos operations: #{chaos_operations.map(&:class).map(&:name).join(', ')}")

# Create and run the server
server = Async::Service::ChaosKitty::Server.new(
	chaos_operations: chaos_operations
)

server.run
