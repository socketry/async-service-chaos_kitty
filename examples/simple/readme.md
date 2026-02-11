# Simple Chaos Kitty Example

This example demonstrates a basic setup of the Chaos Kitty system.

## Running the Example

1. Start the chaos server in one terminal:

```bash
ruby examples/simple/server.rb
```

2. Start one or more workers in separate terminals:

```bash
ruby examples/simple/worker.rb
```

3. Watch as the chaos operations randomly affect the workers!

## What to Expect

Once workers connect to the chaos server, you'll see various chaos operations being unleashed:

- **Hairball** (😾): Workers will randomly experience delays
- **Scratch** (😾): Workers may be randomly terminated
- **Floop** (🌊): Workers will experience memory spikes
- **Zoomies** (🏃): Workers will experience CPU spikes
- **Yowl** (😾): Workers will receive random exceptions

The console output will show when each chaos operation is triggered and which worker is affected.

## Adjusting Chaos Levels

You can modify the `server.rb` file to adjust:

- `interval`: How often to check for chaos opportunities
- `probability`: Likelihood of chaos occurring (0.0 to 1.0)
- Various operation-specific parameters (delays, memory sizes, etc.)

## Testing Resilience

This example is useful for:

- Testing error handling in your application
- Verifying recovery mechanisms
- Stress testing under unpredictable conditions
- Ensuring graceful degradation
