# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "set"
require_relative "loop"

module Async
	module Service
		module ChaosKitty
			# Floop causes random memory spikes in victim processes.
			#
			# Like a cat flopping over dramatically, this chaos operation randomly
			# allocates large amounts of memory to test memory handling and limits.
			class Floop
				# Create a new floop chaos operation.
				#
				# @parameter interval [Integer] How often to check for chaos opportunities.
				# @parameter probability [Float] Probability (0.0 to 1.0) of causing chaos on each check.
				# @parameter min_size_mb [Integer] Minimum memory allocation in megabytes.
				# @parameter max_size_mb [Integer] Maximum memory allocation in megabytes.
				# @parameter hold_duration [Numeric] How long to hold the allocation.
				def initialize(interval: 30, probability: 0.2, min_size_mb: 10, max_size_mb: 100, hold_duration: 2)
					@interval = interval
					@probability = probability
					@min_size_mb = min_size_mb
					@max_size_mb = max_size_mb
					@hold_duration = hold_duration
					@victims = Set.new.compare_by_identity
				end
				
				# @attribute [Set] The set of registered victims.
				attr_reader :victims
				
				# Register a victim with the floop chaos.
				#
				# @parameter chaos_controller [ChaosController] The chaos controller for the victim.
				def register(chaos_controller)
					Console.debug(self, "😺 Registering victim for floop chaos.", id: chaos_controller.id)
					@victims.add(chaos_controller)
				end
				
				# Remove a victim from the floop chaos.
				#
				# @parameter chaos_controller [ChaosController] The chaos controller for the victim.
				def remove(chaos_controller)
					@victims.delete(chaos_controller)
				end
				
				# Get status for the floop chaos.
				#
				# @returns [Hash] Status including victim count and configuration.
				def status
					{
						floop: {
							victims: @victims.size,
							probability: @probability,
							size_range_mb: [@min_size_mb, @max_size_mb],
							hold_duration: @hold_duration
						}
					}
				end
				
				# Unleash a floop on a random victim.
				def unleash_floop
					return if @victims.empty?
					
					# Pick a random victim
					victim = @victims.to_a.sample
					return unless victim
					
					# Check probability
					return unless rand < @probability
					
					# Calculate random size
					size_mb = @min_size_mb + rand(@max_size_mb - @min_size_mb)
					
					Console.info(self, "😾 *FLOOP* Memory spike incoming!", id: victim.id, size_mb: size_mb)
					
					begin
						victim_proxy = victim.connection[:victim]
						if victim_proxy
							victim_proxy.allocate_memory(size_mb: size_mb, hold_duration: @hold_duration)
						end
					rescue => error
						Console.error(self, "Failed to unleash floop!", id: victim.id, exception: error)
					end
				end
				
				# Run the floop chaos operation.
				#
				# @returns [Async::Task] The task that is running the floop chaos.
				def run
					Async do
						Loop.run(interval: @interval) do
							unleash_floop
						end
					end
				end
			end
		end
	end
end
