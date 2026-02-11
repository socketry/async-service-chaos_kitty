# Releases

## v0.1.0

Initial release.

### Features

- Server-client architecture for chaos testing
- Five cat-themed chaos operations:
  - **Hairball**: Random delays and blocking
  - **Scratch**: Random process termination
  - **Floop**: Random memory spikes
  - **Zoomies**: Random CPU spikes
  - **Yowl**: Random exceptions
- Configurable probabilities and intervals for each chaos operation
- Built on async-bus for RPC communication
- Unix domain socket communication
- Example implementations
