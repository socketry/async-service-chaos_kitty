# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require_relative "client"
require_relative "victim_controller"

module Async
	module Service
		module ChaosKitty
			# A worker represents a long running process that can be subjected to chaos by the chaos server.
			#
			# Various chaos operations can be executed on the worker, such as delays, errors, and resource consumption.
			class Worker < Client
				# Run a worker with the given process ID.
				#
				# @parameter process_id [Integer] The process ID to register with the chaos server.
				# @parameter endpoint [IO::Endpoint] The chaos endpoint to connect to.
				def self.run(process_id: Process.pid, endpoint: ChaosKitty.endpoint)
					self.new(process_id: process_id, endpoint: endpoint).run
				end
				
				# Initialize a new worker.
				#
				# @parameter process_id [Integer] The process ID to register with the chaos server.
				# @parameter endpoint [IO::Endpoint] The chaos endpoint to connect to.
				def initialize(process_id: Process.pid, endpoint: ChaosKitty.endpoint)
					super(endpoint: endpoint)
					
					@id = nil
					@process_id = process_id
				end
				
				# @attribute [Integer] The ID assigned by the chaos server.
				attr :id
				
				# @attribute [Integer] The process ID of the worker.
				attr :process_id
				
				protected def connected!(connection)
					super
					
					# Create and bind victim controller
					victim_controller = VictimController.new(self)
					victim_proxy = connection.bind(:victim, victim_controller)
					
					# Register the worker with the chaos server
					# The chaos server allocates a unique ID and returns it
					# This is a synchronous RPC call that will complete before returning
					chaos = connection[:chaos]
					@id = chaos.register(victim_proxy, process_id: @process_id)
				end
			end
		end
	end
end
