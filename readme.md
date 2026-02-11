# Async::Service::ChaosKitty

A chaos monkey system for testing service resilience, implemented with cat-themed chaos operations. ChaosKitty follows the same architecture as [async-service-supervisor](https://github.com/socketry/async-service-supervisor) but instead of monitoring and managing processes, it unleashes controlled chaos to test your system's fault tolerance.

[![Development Status](https://github.com/socketry/async-service-chaos_kitty/workflows/Test/badge.svg)](https://github.com/socketry/async-service-chaos_kitty/actions?workflow=Test)

## Features

  - **Hairball** - Causes random delays and blocking operations
  - **Scratch** - Randomly terminates victim processes
  - **Floop** - Creates random memory spikes and allocations
  - **Zoomies** - Generates random CPU spikes
  - **Yowl** - Raises random exceptions and errors

## Installation

Add this line to your application's Gemfile:

``` ruby
gem "async-service-chaos_kitty"
```

## Usage

### Basic Setup

``` ruby
require "async/service/chaos_kitty"

# Start the chaos server with various chaos operations
chaos_operations = [
	Async::Service::ChaosKitty::Hairball.new(interval: 30, probability: 0.3),
	Async::Service::ChaosKitty::Scratch.new(interval: 60, probability: 0.1),
	Async::Service::ChaosKitty::Floop.new(interval: 30, probability: 0.2),
	Async::Service::ChaosKitty::Zoomies.new(interval: 30, probability: 0.2),
	Async::Service::ChaosKitty::Yowl.new(interval: 45, probability: 0.15)
]

server = Async::Service::ChaosKitty::Server.new(chaos_operations: chaos_operations)
server.run
```

### Connecting Workers (Victims)

In your worker processes:

``` ruby
require "async/service/chaos_kitty"

# Connect to the chaos server
Async::Service::ChaosKitty::Worker.run
```

## Chaos Operations

### Hairball

Causes random delays to simulate blocking operations or slow responses.

``` ruby
Async::Service::ChaosKitty::Hairball.new(
	interval: 30,          # Check every 30 seconds
	probability: 0.3,      # 30% chance to cause chaos
	min_delay: 0.5,        # Minimum delay of 0.5 seconds
	max_delay: 5.0         # Maximum delay of 5 seconds
)
```

### Scratch

Randomly terminates victim processes to test recovery mechanisms.

``` ruby
Async::Service::ChaosKitty::Scratch.new(
	interval: 60,          # Check every 60 seconds
	probability: 0.1,      # 10% chance to cause chaos
	signal: :TERM          # Signal to send (default: TERM)
)
```

### Floop

Creates memory spikes to test memory handling and limits.

``` ruby
Async::Service::ChaosKitty::Floop.new(
	interval: 30,          # Check every 30 seconds
	probability: 0.2,      # 20% chance to cause chaos
	min_size_mb: 10,       # Minimum allocation of 10 MB
	max_size_mb: 100,      # Maximum allocation of 100 MB
	hold_duration: 2       # Hold allocation for 2 seconds
)
```

### Zoomies

Generates CPU spikes to test CPU handling and throttling.

``` ruby
Async::Service::ChaosKitty::Zoomies.new(
	interval: 30,          # Check every 30 seconds
	probability: 0.2,      # 20% chance to cause chaos
	min_duration: 0.5,     # Minimum CPU spin of 0.5 seconds
	max_duration: 3.0      # Maximum CPU spin of 3 seconds
)
```

### Yowl

Raises random exceptions to test error handling and recovery.

``` ruby
Async::Service::ChaosKitty::Yowl.new(
	interval: 45,          # Check every 45 seconds
	probability: 0.15,     # 15% chance to cause chaos
	messages: [            # Custom error messages (optional)
		"Yowl! Chaos kitty is not pleased!",
		"MEOWWWW! Something went wrong!"
	]
)
```

## Architecture

ChaosKitty follows the same client-server architecture as async-service-supervisor:

  - **Server**: Accepts connections from workers and manages chaos operations
  - **Worker**: Connects to the server and becomes a victim of chaos
  - **Chaos Operations**: Independent modules that unleash different types of chaos
  - **Controllers**: Handle RPC communication between server and workers

Workers connect to the chaos server via Unix domain sockets, and chaos operations are executed remotely on victim processes through the async-bus RPC framework.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
