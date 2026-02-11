# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "io/endpoint/unix_endpoint"

module Async
	module Service
		module ChaosKitty
			# Get the chaos kitty IPC endpoint.
			#
			# @parameter path [String] The path for the Unix socket (default: "chaos_kitty.ipc").
			# @returns [IO::Endpoint] The Unix socket endpoint.
			def self.endpoint(path = "chaos_kitty.ipc")
				::IO::Endpoint.unix(path)
			end
		end
	end
end
