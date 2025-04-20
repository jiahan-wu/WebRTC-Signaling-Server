# WebRTC Signaling Server

A lightweight WebSocket-based signaling server for WebRTC applications, built with Swift and Vapor.

## Overview

This signaling server facilitates WebRTC peer connections by:
- Relaying signaling messages between WebRTC peers
- Managing user presence and connection events
- Handling WebRTC signaling protocol (offers, answers, ICE candidates)

## Quick Start

### Local Development

```bash
swift build
swift run
```

The server will be available at `http://localhost:8080`.

## API

### WebSocket Endpoint

Connect to the WebSocket endpoint at `/signals` to exchange WebRTC signaling data.

### Event Types

The server supports the following event types:

- `user-joined`: Announces when a new user joins
- `offer`: Contains SDP offer for establishing connection
- `answer`: Contains SDP answer in response to an offer
- `ice-candidate-generated`: Shares ICE candidates for connection
- `ice-candidates-removed`: Notifies when ICE candidates are removed

## Architecture

- Built on Swift Vapor framework
- Uses Swift Concurrency (async/await)
- Utilizes Swift NIO for non-blocking networking
- Actor-based client management for thread safety

## Client Integration

Clients should:
1. Connect to the WebSocket endpoint
2. Announce themselves with a user-joined event
3. Listen for other peers joining
4. Exchange WebRTC offers/answers and ICE candidates
5. Establish direct peer connections once signaling is complete

## License

[MIT License](LICENSE)