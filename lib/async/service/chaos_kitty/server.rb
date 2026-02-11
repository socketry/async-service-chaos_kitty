# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async/bus/server"
require_relative "chaos_controller"
require_relative "victim_controller"

module Async
	module Service
		module ChaosKitty
			# The server represents the main chaos process which is responsible for unleashing chaos on connected victims.
			#
			# Various chaos operations can be executed by the server, such as causing delays, raising errors, and consuming resources. The server is also responsible for managing the lifecycle of the chaos operations, which can be used to wreak havoc on the connected workers.
			class Server < Async::Bus::Server
				# Initialize a new chaos server.
				#
				# @parameter chaos_operations [Array] The chaos operations to run.
				# @parameter endpoint [IO::Endpoint] The endpoint to listen on.
				def initialize(chaos_operations: [], endpoint: ChaosKitty.endpoint, **options)
					super(endpoint, **options)
					
					@chaos_operations = chaos_operations
					@controllers = {}
					@next_id = 0
				end
				
				attr :chaos_operations
				attr :controllers
				
				# Allocate the next unique sequential ID.
				#
				# @returns [Integer] A unique sequential ID.
				def next_id
					@next_id += 1
				end
				
				# Add a controller to the server.
				#
				# Validates that the controller has been properly registered with an ID
				# and checks for ID collisions before adding it to tracking.
				#
				# @parameter controller [ChaosController] The controller to add.
				# @raises [RuntimeError] If the controller doesn't have an ID or if there's an ID collision.
				def add(controller)
					unless id = controller.id
						raise RuntimeError, "Controller must be registered with an ID before being added!"
					end
					
					if @controllers.key?(id)
						raise RuntimeError, "Controller already registered: id=#{id}"
					end
					
					@controllers[id] = controller
					
					# Notify chaos operations with the chaos controller:
					@chaos_operations.each do |chaos|
						chaos.register(controller)
					rescue => error
						Console.error(self, "Error while registering victim!", chaos: chaos, exception: error)
					end
				end
				
				# Remove a victim connection from the chaos server.
				#
				# Notifies all chaos operations and removes the connection from tracking.
				#
				# @parameter controller [ChaosController] The controller to remove.
				def remove(controller)
					if id = controller.id
						@controllers.delete(id)
					end
					
					# Notify chaos operations with the chaos controller:
					@chaos_operations.each do |chaos|
						chaos.remove(controller)
					rescue => error
						Console.error(self, "Error while removing victim!", chaos: chaos, exception: error)
					end
				end
				
				# Run the chaos server.
				#
				# Starts all chaos operations and accepts connections from victims.
				#
				# @parameter parent [Async::Task] The parent task to run under.
				def run
					Sync do |task|
						# Start all chaos operations:
						@chaos_operations.each do |chaos|
							chaos.run
						rescue => error
							Console.error(self, "Error while starting chaos!", chaos: chaos, exception: error)
						end
						
						# Accept connections from victims:
						self.accept do |connection|
							# Create a chaos controller for this connection:
							chaos_controller = ChaosController.new(self, connection)
							
							# Bind chaos controller:
							connection.bind(:chaos, chaos_controller)
							
							# Run the connection:
							connection.run
						ensure
							self.remove(chaos_controller)
						end
						
						task.children&.each(&:wait)
					ensure
						task.stop
					end
				end
			end
		end
	end
end
