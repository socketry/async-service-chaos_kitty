# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async/bus/controller"

module Async
	module Service
		module ChaosKitty
			# Controller for chaos operations.
			#
			# Handles registration of victims, victim lookup, and status queries.
			class ChaosController < Async::Bus::Controller
				def initialize(server, connection)
					@server = server
					@connection = connection
					
					@id = nil
					@process_id = nil
					@victim = nil
				end
				
				# @attribute [Server] The server instance.
				attr :server
				
				# @attribute [Connection] The connection instance.
				attr :connection
				
				# @attribute [Integer] The ID assigned to this victim.
				attr :id
				
				# @attribute [Integer] The process ID of the victim.
				attr :process_id
				
				# @attribute [Proxy] The proxy to the victim controller.
				attr :victim
				
				# Register a victim connection with the chaos server.
				#
				# Allocates a unique sequential ID, stores the victim controller proxy,
				# and notifies all chaos operations of the new connection.
				#
				# @parameter victim [Proxy] The proxy to the victim controller.
				# @parameter process_id [Integer] The process ID of the victim.
				# @returns [Integer] The connection ID assigned to the victim.
				def register(victim, process_id:)
					raise RuntimeError, "Already registered" if @id
					
					@id = @server.next_id
					@process_id = process_id
					@victim = victim
					
					@server.add(self)
					
					return @id
				end
				
				# Get a victim controller proxy by connection ID.
				#
				# Returns a proxy to the victim controller that can be used to invoke
				# operations directly on the victim. The proxy uses multi-hop forwarding
				# to route calls through the chaos server to the victim.
				#
				# @parameter id [Integer] The ID of the victim.
				# @returns [Proxy] A proxy to the victim controller.
				# @raises [ArgumentError] If the connection ID is not found.
				def [](id)
					unless id
						raise ArgumentError, "Missing 'id' parameter"
					end
					
					chaos_controller = @server.controllers[id]
					
					unless chaos_controller
						raise ArgumentError, "Connection not found: #{id}"
					end
					
					victim = chaos_controller.victim
					
					unless victim
						raise ArgumentError, "Victim controller not found for connection: #{id}"
					end
					
					return victim
				end
				
				# List all registered victim IDs.
				#
				# @returns [Array(Integer)] An array of IDs for all registered victims.
				def keys
					@server.controllers.keys
				end
				
				# Query the status of the chaos server and all connected victims.
				#
				# Returns an array of status information from each chaos operation.
				# Each chaos operation provides its own status representation.
				#
				# @returns [Array] An array of status information from each chaos operation.
				def status
					@server.chaos_operations.map do |chaos|
						begin
							chaos.status
						rescue => error
							error
						end
					end.compact
				end
			end
		end
	end
end
