# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "set"
require_relative "loop"

module Async
	module Service
		module ChaosKitty
			# Zoomies causes random CPU spikes in victim processes.
			#
			# Like a cat getting the zoomies and running around wildly, this chaos
			# operation randomly consumes CPU to test CPU handling and throttling.
			class Zoomies
				# Create a new zoomies chaos operation.
				#
				# @parameter interval [Integer] How often to check for chaos opportunities.
				# @parameter probability [Float] Probability (0.0 to 1.0) of causing chaos on each check.
				# @parameter min_duration [Numeric] Minimum CPU spin duration in seconds.
				# @parameter max_duration [Numeric] Maximum CPU spin duration in seconds.
				def initialize(interval: 30, probability: 0.2, min_duration: 0.5, max_duration: 3.0)
					@interval = interval
					@probability = probability
					@min_duration = min_duration
					@max_duration = max_duration
					@victims = Set.new.compare_by_identity
				end
				
				# @attribute [Set] The set of registered victims.
				attr_reader :victims
				
				# Register a victim with the zoomies chaos.
				#
				# @parameter chaos_controller [ChaosController] The chaos controller for the victim.
				def register(chaos_controller)
					Console.debug(self, "😺 Registering victim for zoomies chaos.", id: chaos_controller.id)
					@victims.add(chaos_controller)
				end
				
				# Remove a victim from the zoomies chaos.
				#
				# @parameter chaos_controller [ChaosController] The chaos controller for the victim.
				def remove(chaos_controller)
					@victims.delete(chaos_controller)
				end
				
				# Get status for the zoomies chaos.
				#
				# @returns [Hash] Status including victim count and configuration.
				def status
					{
						zoomies: {
							victims: @victims.size,
							probability: @probability,
							duration_range: [@min_duration, @max_duration]
						}
					}
				end
				
				# Unleash the zoomies on a random victim.
				def unleash_zoomies
					return if @victims.empty?
					
					# Pick a random victim
					victim = @victims.to_a.sample
					return unless victim
					
					# Check probability
					return unless rand < @probability
					
					# Calculate random duration
					duration = @min_duration + rand * (@max_duration - @min_duration)
					
					Console.info(self, "😾 *ZOOM ZOOM* CPU spike incoming!", id: victim.id, duration: duration)
					
					begin
						victim_proxy = victim.connection[:victim]
						if victim_proxy
							victim_proxy.cpu_spin(duration: duration)
						end
					rescue => error
						Console.error(self, "Failed to unleash zoomies!", id: victim.id, exception: error)
					end
				end
				
				# Run the zoomies chaos operation.
				#
				# @returns [Async::Task] The task that is running the zoomies chaos.
				def run
					Async do
						Loop.run(interval: @interval) do
							unleash_zoomies
						end
					end
				end
			end
		end
	end
end
