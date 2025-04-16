//
//  WebSocketsController.swift
//  SignalingServer
//
//  Created by Jia-Han Wu on 2025/4/13.
//

import Vapor

struct WebSocketsController: RouteCollection {
        
    private actor Storage {
        private var webSockets: [WebSocket] = []
        
        func append(_ webSocket: WebSocket) {
            webSockets.append(webSocket)
        }
        
        func remove(_ webSocket: WebSocket) {
            if let index = webSockets.firstIndex(where: { $0 === webSocket}) {
                webSockets.remove(at: index)
            }
        }
        
        func all() -> [WebSocket] {
            webSockets
        }
    }
    
    private let storage = Storage()
    
    private let jsonDecoder = JSONDecoder()
    
    func boot(routes: any RoutesBuilder) throws {
        routes.webSocket("signals") { request, webSocket async in
            request.logger.info("New WebSocket connection established.")
            
            await storage.append(webSocket)
            
            webSocket.onBinary { webSocket, data async in
                do {
                    let event = try jsonDecoder.decode(Event.self, from: data)
                    
                    switch event.type {
                    case Event.UserJoinedEvent.type:
                        let userJoinedEvent = try jsonDecoder.decode(Event.UserJoinedEvent.self, from: data)
                        request.logger.info("Received user-joined event: \(userJoinedEvent.userId)")
                        for webSocket in await storage.all() {
                            webSocket.send(data)
                        }
                    case Event.OfferEvent.type:
                        let offerEvent = try jsonDecoder.decode(Event.OfferEvent.self, from: data)
                        request.logger.info("Received offer event: \(offerEvent.from) -> \(offerEvent.to)")
                        for webSocket in await storage.all() {
                            webSocket.send(data)
                        }
                    case Event.AnswerEvent.type:
                        let answerEvent = try jsonDecoder.decode(Event.AnswerEvent.self, from: data)
                        request.logger.info("Received answer event: \(answerEvent.from) -> \(answerEvent.to)")
                        for webSocket in await storage.all() {
                            webSocket.send(data)
                        }
                    case Event.ICECandidateGeneratedEvent.type:
                        let iceCandidateGeneratedEvent = try jsonDecoder.decode(Event.ICECandidateGeneratedEvent.self, from: data)
                        request.logger.info("Received ice-candidate-generated event: \(iceCandidateGeneratedEvent.from) -> \(iceCandidateGeneratedEvent.to)")
                        for webSocket in await storage.all() {
                            webSocket.send(data)
                        }
                    case Event.ICECandidatesRemovedEvent.type:
                        let iceCandidatesRemovedEvent = try jsonDecoder.decode(Event.ICECandidatesRemovedEvent.self, from: data)
                        request.logger.info("Received ice-candidates-removed event: \(iceCandidatesRemovedEvent.from) -> \(iceCandidatesRemovedEvent.to)")
                        for webSocket in await storage.all() {
                            webSocket.send(data)
                        }
                    default:
                        break
                    }
                } catch {
                    request.logger.error("Falied to decode event: \(error)")
                }
            }
            
            webSocket.onClose.whenComplete { result in
                request.logger.info("WebSocket connection closed: \(result)")
                Task {
                    await storage.remove(webSocket)
                }
            }
        }
    }
    
}
