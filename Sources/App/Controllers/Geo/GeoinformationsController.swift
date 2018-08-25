import Vapor
import FluentPostgreSQL
//import FluentQuery

struct GeoinformationsController: RouteCollection {
    
    func boot(router: Router) throws {
        let geoinformationsRoute = router.grouped("api","geoinformations")
        
        geoinformationsRoute.get(use: getAllHandler)
        geoinformationsRoute.get(Geoinformation.parameter, use: getHandler)
        geoinformationsRoute.post(Geoinformation.self, use: createHandler)
        geoinformationsRoute.delete(Geoinformation.parameter, use: deleteHandler)
        geoinformationsRoute.get(Geoinformation.parameter, "groups", use: getGroupsHandler)
        geoinformationsRoute.post(Geoinformation.parameter, "groups", Geogroup.parameter, use: addGroupHandler)
        geoinformationsRoute.get("overview", GeoOverview.parameter, use: getGeoOverview)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Geoinformation]> {
        return Geoinformation.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Geoinformation> {
        return try req.parameters.next(Geoinformation.self)
    }
    
    func createHandler(_ req: Request, geoinformation: Geoinformation) throws -> Future<Geoinformation> {
        return geoinformation.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Geoinformation.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    func getGroupsHandler(_ req: Request) throws -> Future<[Geogroup]> {
        return try req.parameters.next(Geoinformation.self).flatMap(to: [Geogroup].self) { group in
            try group.geogroups.query(on: req).all()
        }
    }
    
    func addGroupHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Geoinformation.self),
                           req.parameters.next(Geogroup.self)) { info, group in
            let pivot = try GroupForGeoinformation(info.requireID(), group.requireID())
            return pivot.save(on: req).transform(to: .created)
        }
    }
    
    func getGeoOverview(_ req: Request) throws -> Future<GeoOverview> {
        return try req.parameters.next(GeoOverview.self)
    }
}
