# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "set"
require_relative "loop"

module Async
	module Service
		module ChaosKitty
			# Yowl causes random exceptions in victim processes.
			#
			# Like a cat yowling in the night, this chaos operation randomly
			# raises errors to test error handling and recovery.
			class Yowl
				# Create a new yowl chaos operation.
				#
				# @parameter interval [Integer] How often to check for chaos opportunities.
				# @parameter probability [Float] Probability (0.0 to 1.0) of causing chaos on each check.
				# @parameter messages [Array<String>] Possible error messages to use.
				def initialize(interval: 45, probability: 0.15, messages: nil)
					@interval = interval
					@probability = probability
					@messages = messages || [
						"Yowl! Chaos kitty is not pleased!",
						"MEOWWWW! Something went wrong!",
						"Hiss! An unexpected error occurred!",
						"*Angry cat noises*",
						"The chaos kitty demands tribute!"
					]
					@victims = Set.new.compare_by_identity
				end
				
				# @attribute [Set] The set of registered victims.
				attr_reader :victims
				
				# Register a victim with the yowl chaos.
				#
				# @parameter chaos_controller [ChaosController] The chaos controller for the victim.
				def register(chaos_controller)
					Console.debug(self, "😺 Registering victim for yowl chaos.", id: chaos_controller.id)
					@victims.add(chaos_controller)
				end
				
				# Remove a victim from the yowl chaos.
				#
				# @parameter chaos_controller [ChaosController] The chaos controller for the victim.
				def remove(chaos_controller)
					@victims.delete(chaos_controller)
				end
				
				# Get status for the yowl chaos.
				#
				# @returns [Hash] Status including victim count and configuration.
				def status
					{
						yowl: {
							victims: @victims.size,
							probability: @probability,
							message_variants: @messages.size
						}
					}
				end
				
				# Unleash a yowl on a random victim.
				def unleash_yowl
					return if @victims.empty?
					
					# Pick a random victim
					victim = @victims.to_a.sample
					return unless victim
					
					# Check probability
					return unless rand < @probability
					
					# Pick a random message
					message = @messages.sample
					
					Console.info(self, "😾 *YOWWWWL* Error incoming!", id: victim.id, message: message)
					
					begin
						victim_proxy = victim.connection[:victim]
						if victim_proxy
							victim_proxy.raise_error(message: message)
						end
					rescue => error
						# This is expected - we're causing an error!
						Console.debug(self, "Yowl successful (error was raised)!", id: victim.id)
					end
				end
				
				# Run the yowl chaos operation.
				#
				# @returns [Async::Task] The task that is running the yowl chaos.
				def run
					Async do
						Loop.run(interval: @interval) do
							unleash_yowl
						end
					end
				end
			end
		end
	end
end
