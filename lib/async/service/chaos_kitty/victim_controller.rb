# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async/bus/controller"

module Async
	module Service
		module ChaosKitty
			# Controller for victim operations.
			#
			# Handles chaos operations that can be invoked on victims.
			class VictimController < Async::Bus::Controller
				def initialize(worker)
					@worker = worker
				end
				
				# Force a delay/block for the specified duration.
				#
				# This simulates blocking operations or slow responses.
				#
				# @parameter duration [Numeric] The duration in seconds to block for.
				# @returns [Hash] Confirmation with actual duration.
				def delay(duration:)
					Console.warn(self, "😴 Hairball incoming! Blocking...", duration: duration)
					Fiber.blocking{sleep(duration)}
					return {delayed: duration}
				end
				
				# Raise an exception in the victim process.
				#
				# This simulates unexpected errors.
				#
				# @parameter message [String] The error message.
				# @returns [Hash] Should not return if successful.
				def raise_error(message: "Yowl! Chaos kitty struck!")
					Console.warn(self, "😾 Yowl! Raising error...", message: message)
					raise RuntimeError, message
				end
				
				# Allocate memory to simulate memory pressure.
				#
				# This creates memory spikes.
				#
				# @parameter size_mb [Integer] The amount of memory to allocate in megabytes.
				# @parameter hold_duration [Numeric] How long to hold the allocation.
				# @returns [Hash] Confirmation with allocated size.
				def allocate_memory(size_mb:, hold_duration: 1)
					Console.warn(self, "🌊 Floop! Allocating memory...", size_mb: size_mb)
					# Allocate roughly size_mb megabytes
					_bloat = Array.new((size_mb * 1024 * 1024) / 8){rand}
					Fiber.blocking{sleep(hold_duration)} if hold_duration > 0
					return {allocated_mb: size_mb, held_for: hold_duration}
				end
				
				# Consume CPU cycles.
				#
				# This simulates CPU spikes.
				#
				# @parameter duration [Numeric] How long to spin the CPU.
				# @returns [Hash] Confirmation with duration.
				def cpu_spin(duration:)
					Console.warn(self, "🏃 Zoomies! Spinning CPU...", duration: duration)
					end_time = Time.now + duration
					count = 0
					while Time.now < end_time
						count += 1
						Math.sqrt(count)
					end
					return {cpu_spun: duration, iterations: count}
				end
				
				# Trigger garbage collection.
				#
				# This can cause GC pauses.
				#
				# @returns [Hash] GC stats.
				def trigger_gc
					Console.warn(self, "🧹 Triggering garbage collection...")
					before = GC.stat
					GC.start
					after = GC.stat
					return {
						gc_triggered: true,
						collections_before: before[:count],
						collections_after: after[:count]
					}
				end
			end
		end
	end
end
