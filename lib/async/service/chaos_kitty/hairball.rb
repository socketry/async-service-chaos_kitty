# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "set"
require_relative "loop"

module Async
	module Service
		module ChaosKitty
			# Hairball causes random delays and blocking in victim processes.
			#
			# Like a cat hacking up a hairball, this chaos operation randomly
			# blocks victims, simulating slow responses or stuck operations.
			class Hairball
				# Create a new hairball chaos operation.
				#
				# @parameter interval [Integer] How often to check for chaos opportunities.
				# @parameter probability [Float] Probability (0.0 to 1.0) of causing chaos on each check.
				# @parameter min_delay [Numeric] Minimum delay duration in seconds.
				# @parameter max_delay [Numeric] Maximum delay duration in seconds.
				def initialize(interval: 30, probability: 0.3, min_delay: 0.5, max_delay: 5.0)
					@interval = interval
					@probability = probability
					@min_delay = min_delay
					@max_delay = max_delay
					@victims = Set.new.compare_by_identity
				end
				
				# @attribute [Set] The set of registered victims.
				attr_reader :victims
				
				# Register a victim with the hairball chaos.
				#
				# @parameter chaos_controller [ChaosController] The chaos controller for the victim.
				def register(chaos_controller)
					Console.debug(self, "😺 Registering victim for hairball chaos.", id: chaos_controller.id)
					@victims.add(chaos_controller)
				end
				
				# Remove a victim from the hairball chaos.
				#
				# @parameter chaos_controller [ChaosController] The chaos controller for the victim.
				def remove(chaos_controller)
					@victims.delete(chaos_controller)
				end
				
				# Get status for the hairball chaos.
				#
				# @returns [Hash] Status including victim count and configuration.
				def status
					{
						hairball: {
							victims: @victims.size,
							probability: @probability,
							delay_range: [@min_delay, @max_delay]
						}
					}
				end
				
				# Unleash a hairball on a random victim.
				def unleash_hairball
					return if @victims.empty?
					
					# Pick a random victim
					victim = @victims.to_a.sample
					return unless victim
					
					# Check probability
					return unless rand < @probability
					
					# Calculate random delay
					delay = @min_delay + rand * (@max_delay - @min_delay)
					
					Console.info(self, "😾 *HACK* *HACK* Hairball time!", id: victim.id, delay: delay)
					
					begin
						victim_proxy = victim.connection[:victim]
						if victim_proxy
							victim_proxy.delay(duration: delay)
						end
					rescue => error
						Console.error(self, "Failed to unleash hairball!", id: victim.id, exception: error)
					end
				end
				
				# Run the hairball chaos operation.
				#
				# @returns [Async::Task] The task that is running the hairball chaos.
				def run
					Async do
						Loop.run(interval: @interval) do
							unleash_hairball
						end
					end
				end
			end
		end
	end
end
