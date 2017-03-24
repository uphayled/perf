import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

class Dic{
	let names = ["usernames":[
	    ["first":"Chris", "Last":"Chadillon", "username":"cbcdiver", "password":"pencil99"],
	    ["first":"Alice", "Last":"Chadillon", "username":"dogs", "password":["pencil99","groundhog"]]
	]]

	func getUser(user:String) -> String{
        
        return ""
    }
	init(){

	}

}

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"
var dic = Dic()
var routes = Routes()

routes.add(method: .get, uri: "/json/all") {
    request, response in
    do {
        try response.setBody(json: dic.names)
            response.setHeader(.contentType, value: "application/json")
            response.completed()

    } catch {
        response.setBody(string: "Error handling request: \(error)")
        response.completed()
    }
}

routes.add(method: .get, uri: "/json/username/{username}", handler: {
    request, response in
    do {

	if let userName = request.urlVariables["username"] {

	    response.setBody(string: dic.getUser(user:userName))
    	response.setHeader(.contentType, value: "application/json")
    	response.completed()
	}

    }


    response.completed()
})

server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
