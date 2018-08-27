import Vapor

struct MessagesController: RouteCollection {
    func boot(router: Router) throws {
        let messagesRoute = router.grouped("api","messages")
        messagesRoute.get(use: getAllHandler)
        messagesRoute.post(Message.self, use: createHandler)
        messagesRoute.get(Message.parameter, use: getHandler)
        messagesRoute.delete(Message.parameter, use: deleteHandler)
        messagesRoute.put(Message.parameter, use: updateHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Message]> {
        return Message.query(on: req).all()
    }
    
    func createHandler(_ req: Request, message: Message) throws -> Future<Message> {
        return message.save(on: req)
    }
    
    func getHandler(_ req: Request) throws -> Future<Message> {
        return try req.parameters.next(Message.self)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Message.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Message> {
        return try flatMap(to: Message.self,
                           req.parameters.next(Message.self),
                           req.content.decode(Message.self)) { message, updatedMessage in
                            message.title = updatedMessage.title
                            message.scheduleId = updatedMessage.scheduleId
                            return message.save(on: req)
        }
    }
}
