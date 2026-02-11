# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "set"
require_relative "loop"

module Async
	module Service
		module ChaosKitty
			# Scratch randomly kills victim processes.
			#
			# Like a cat scratching furniture, this chaos operation randomly
			# terminates victim processes to test resilience and recovery.
			class Scratch
				# Create a new scratch chaos operation.
				#
				# @parameter interval [Integer] How often to check for chaos opportunities.
				# @parameter probability [Float] Probability (0.0 to 1.0) of causing chaos on each check.
				# @parameter signal [Symbol] The signal to send when scratching.
				def initialize(interval: 60, probability: 0.1, signal: :TERM)
					@interval = interval
					@probability = probability
					@signal = signal
					@victims = Set.new.compare_by_identity
				end
				
				# @attribute [Set] The set of registered victims.
				attr_reader :victims
				
				# Register a victim with the scratch chaos.
				#
				# @parameter chaos_controller [ChaosController] The chaos controller for the victim.
				def register(chaos_controller)
					Console.debug(self, "😺 Registering victim for scratch chaos.", id: chaos_controller.id)
					@victims.add(chaos_controller)
				end
				
				# Remove a victim from the scratch chaos.
				#
				# @parameter chaos_controller [ChaosController] The chaos controller for the victim.
				def remove(chaos_controller)
					@victims.delete(chaos_controller)
				end
				
				# Get status for the scratch chaos.
				#
				# @returns [Hash] Status including victim count and configuration.
				def status
					{
						scratch: {
							victims: @victims.size,
							probability: @probability,
							signal: @signal
						}
					}
				end
				
				# Unleash a scratch on a random victim.
				def unleash_scratch
					return if @victims.empty?
					
					# Pick a random victim
					victim = @victims.to_a.sample
					return unless victim
					
					# Check probability
					return unless rand < @probability
					
					process_id = victim.process_id
					return unless process_id
					
					Console.info(self, "😾 *SCRATCH* Taking down a victim!", id: victim.id, process_id: process_id, signal: @signal)
					
					begin
						Process.kill(@signal, process_id)
					rescue Errno::ESRCH
						Console.warn(self, "Process already gone!", process_id: process_id)
					rescue => error
						Console.error(self, "Failed to scratch victim!", process_id: process_id, exception: error)
					end
				end
				
				# Run the scratch chaos operation.
				#
				# @returns [Async::Task] The task that is running the scratch chaos.
				def run
					Async do
						Loop.run(interval: @interval) do
							unleash_scratch
						end
					end
				end
			end
		end
	end
end
