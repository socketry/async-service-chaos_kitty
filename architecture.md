# Architecture

This document describes the architecture of async-service-chaos_kitty, which follows the same pattern as async-service-supervisor.

## Overview

ChaosKitty is a chaos monkey system for testing service resilience. It uses a client-server architecture where workers connect to a central chaos server, and various chaos operations are unleashed on the connected workers.

## Components

### Core Components

#### Server (`server.rb`)
The main chaos server that:
- Accepts connections from workers (victims)
- Manages chaos operations
- Coordinates between chaos operations and connected victims
- Tracks all connected victims via controllers

#### Worker (`worker.rb`)
A worker process that:
- Connects to the chaos server
- Registers itself as a victim
- Exposes victim controller methods for chaos operations
- Runs the main application logic

#### Client (`client.rb`)
Base client class for connecting to the chaos server. Extended by Worker.

### Controllers

#### ChaosController (`chaos_controller.rb`)
Server-side controller that:
- Manages victim registration
- Provides access to victim proxies
- Handles status queries
- Tracks victim metadata (ID, process ID, connection)

#### VictimController (`victim_controller.rb`)
Client-side controller that:
- Exposes methods that can be invoked by chaos operations
- Implements chaos actions: delay, raise_error, allocate_memory, cpu_spin, trigger_gc
- Logs chaos events

### Chaos Operations

All chaos operations follow the same pattern:
- `register(chaos_controller)`: Called when a new victim connects
- `remove(chaos_controller)`: Called when a victim disconnects
- `status()`: Returns current status
- `run()`: Starts the chaos operation loop

#### Hairball (`hairball.rb`)
Causes random delays and blocking operations.

**Parameters:**
- `interval`: How often to check for chaos opportunities
- `probability`: Chance of causing chaos (0.0-1.0)
- `min_delay`: Minimum delay duration
- `max_delay`: Maximum delay duration

**Effect:** Calls `victim.delay(duration:)` on random victims

#### Scratch (`scratch.rb`)
Randomly terminates victim processes.

**Parameters:**
- `interval`: How often to check for chaos opportunities
- `probability`: Chance of causing chaos (0.0-1.0)
- `signal`: Signal to send to process

**Effect:** Sends signal to victim's process ID

#### Floop (`floop.rb`)
Creates random memory spikes.

**Parameters:**
- `interval`: How often to check for chaos opportunities
- `probability`: Chance of causing chaos (0.0-1.0)
- `min_size_mb`: Minimum memory allocation
- `max_size_mb`: Maximum memory allocation
- `hold_duration`: How long to hold the allocation

**Effect:** Calls `victim.allocate_memory(size_mb:, hold_duration:)`

#### Zoomies (`zoomies.rb`)
Generates random CPU spikes.

**Parameters:**
- `interval`: How often to check for chaos opportunities
- `probability`: Chance of causing chaos (0.0-1.0)
- `min_duration`: Minimum CPU spin duration
- `max_duration`: Maximum CPU spin duration

**Effect:** Calls `victim.cpu_spin(duration:)`

#### Yowl (`yowl.rb`)
Raises random exceptions.

**Parameters:**
- `interval`: How often to check for chaos opportunities
- `probability`: Chance of causing chaos (0.0-1.0)
- `messages`: Array of possible error messages

**Effect:** Calls `victim.raise_error(message:)`

## Communication Flow

1. **Worker Startup:**
   - Worker creates a connection to chaos server
   - Worker creates VictimController and binds it
   - Worker calls `chaos.register(victim_proxy, process_id:)`
   - Server allocates ID and calls `chaos_operation.register()` for each operation

2. **Chaos Execution:**
   - Chaos operation runs in a loop at specified interval
   - On each iteration, randomly selects a victim
   - Checks probability to determine if chaos should occur
   - Invokes remote method on victim via proxy
   - Victim controller executes the chaos action

3. **Worker Shutdown:**
   - Connection closes
   - Server calls `chaos_operation.remove()` for each operation
   - Controller is removed from tracking

## IPC Mechanism

- Uses Unix domain sockets for inter-process communication
- Default socket path: `chaos_kitty.ipc`
- Built on async-bus for RPC capabilities
- Supports multi-hop forwarding for proxy calls

## Threading Model

- Built on Async framework for cooperative concurrency
- Each chaos operation runs in its own Async task
- Connection handling is concurrent
- Chaos operations execute independently

## Comparison with async-service-supervisor

| Supervisor | ChaosKitty | Purpose |
|------------|------------|---------|
| Monitor | Chaos Operation | Watches/affects workers |
| MemoryMonitor | Floop | Memory-related |
| ProcessMonitor | Scratch | Process-related |
| Worker | Worker | Connects to server |
| SupervisorController | ChaosController | Server-side RPC |
| WorkerController | VictimController | Client-side RPC |
| Monitors health | Causes chaos | Core function |

Both systems share the same architectural pattern but serve opposite purposes: one monitors and maintains health, the other intentionally causes problems to test resilience.
