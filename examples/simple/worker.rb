#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

# This is a simple example of a worker that connects to the chaos server.
# The worker will be subjected to various chaos operations.

require "async/service/chaos_kitty"
require "console"

Console.logger.info("Starting worker (victim)...", process_id: Process.pid)

Async do |task|
	# Connect to the chaos server and become a victim
	Async::Service::ChaosKitty::Worker.run
	
	sleep
rescue => error
	Console.error(self, "Worker error:", exception: error)
	raise
end
