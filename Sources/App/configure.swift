import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    
    let corsConfig = CORSMiddleware.Configuration(
        allowedOrigin: .originBased,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent],
        exposedHeaders: [
            HTTPHeaderName.authorization.description,
            HTTPHeaderName.contentLength.description,
            HTTPHeaderName.contentType.description,
            HTTPHeaderName.contentDisposition.description,
            HTTPHeaderName.cacheControl.description,
            HTTPHeaderName.expires.description
        ]
    )
    
    middlewares.use(CORSMiddleware(configuration: corsConfig))
    
    services.register(middlewares)
    
    // Configure a database
    var databases = DatabasesConfig()
    let hostname = Environment.get("104.248.17.84") ?? "104.248.17.84"
    let username = Environment.get("vapor") ?? "vapor"
    let databaseName = Environment.get("vapor") ?? "vapor"
    let password = Environment.get("wUvX04C45818j489") ?? "wUvX04C45818j489"
    
    //let hostname = Environment.get("localhost") ?? "localhost"
    //let username = Environment.get("daniel") ?? "daniel"
    //let databaseName = Environment.get("daniel") ?? "daniel"
    //let password = Environment.get("") ?? nil
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        username: username,
        database: databaseName,
        password: password)
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    // Configure migrations
    var migrations = MigrationConfig()
    
    // Geo
    migrations.add(model: Geogroup.self, database: .psql)
    migrations.add(model: Geolocation.self, database: .psql)
    migrations.add(model: Geoinformation.self, database: .psql)
    migrations.add(model: GroupForGeoinformation.self, database: .psql)
    migrations.add(model: ParentOfGeogroup.self, database: .psql)
    migrations.add(model: GeoOverview.self, database: .psql)
    
    // Schedules
    migrations.add(model: Event.self, database: .psql)
    migrations.add(model: Schedule.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: Venue.self, database: .psql)
    migrations.add(model: Track.self, database: .psql)
    migrations.add(model: Message.self, database: .psql)
    migrations.add(model: EventCategoryPivot.self, database: .psql)
    
    services.register(migrations)
    
    // Configure the rest of your application here
}
