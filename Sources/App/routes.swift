import Routing
import Vapor
import Fluent
import FluentQuery


public func routes(_ router: Router) throws {

    router.get("hello") { req in
        return "Hello, world!"
    }
    
    struct ResultsRequest: Codable {
        var searchTerm: String
    }
    
    // example: http://localhost:8080/api/geosearch?searchTerm=philo
    router.get("api", "geosearch") { req -> Future<[GeoOverview]> in
        
        let query = try req.query.decode(ResultsRequest.self)
        let searchTerm = query.searchTerm
        
        return req.requestPooledConnection(to: .psql).flatMap { conn -> EventLoopFuture<[GeoOverview]> in
            defer { try? req.releasePooledConnection(conn, to: .psql) }
            let fq = FluentQuery()
                .select("*")
                .from(GeoOverview.self)
                .where(FQWhere(\GeoOverview.document ~~~ ["german", "\(searchTerm)"]))
            return try fq
                .execute(on: conn)
                .decode(GeoOverview.self)
        }
    }
    
    struct ScheduleRequest: Codable {
        var scheduleId: String
    }
    
    let eventsController = EventsController()
    try router.register(collection: eventsController)
    
    let schedulesController = SchedulesController()
    try router.register(collection: schedulesController)
    
    let venuesController = VenuesController()
    try router.register(collection: venuesController)
    
    let categoriesController = CategoriesController()
    try router.register(collection: categoriesController)
    
    let messagesController = MessagesController()
    try router.register(collection: messagesController)
    
    let geolocationsController = GeolocationsController()
    try router.register(collection: geolocationsController)
    
    let geoinformationsController = GeoinformationsController()
    try router.register(collection: geoinformationsController)
    
    let geogroupsController = GeogroupsController()
    try router.register(collection: geogroupsController)
    
}
