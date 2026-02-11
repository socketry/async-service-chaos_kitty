# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async/bus/client"

module Async
	module Service
		module ChaosKitty
			# A client provides a mechanism to connect to a chaos server in order to execute operations.
			class Client < Async::Bus::Client
				# Initialize a new client.
				#
				# @parameter endpoint [IO::Endpoint] The chaos endpoint to connect to.
				def initialize(endpoint: ChaosKitty.endpoint, **options)
					super(endpoint, **options)
				end
			end
		end
	end
end
