import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

class Dic{
	init(){
		self.debugd = ["":""]
		self.debug = ""
	}
	
	let names = ["usernames":[
	    ["first":"Chris", "Last":"Chadillon", "username":"cbcdiver", "password":"pencil99"],
	    ["first":"Alice", "Last":"Chadillon", "username":"dogs", "password":["pencil99","groundhog"]]
	]]
	let notfound = ["result":"no account"]
	let rtrue = ["result":"true"]
	let rfalse = ["result":"false"]
	var debug : String
	var debugd : Dictionary<String, Any>
	var debug_out: String {
        get {
						let d = (self.debugd.flatMap({ (key, value) -> String in
								return "\(key)=\(value)"
						}) as Array).joined(separator: ";")

            return d+debug
        }
    }


	func getUser(user:String) -> Dictionary<String, Any>{
				for (accounts) in names["usernames"]! {
					if user == accounts["username"] as! String{
						return ["accounts":accounts]
					}
				}
				return ["result":"no account"]
  }
	func userLogin(l_user:String,l_pass:String) -> Dictionary<String, Any>{

				let found = getUser(user:l_user)
				let account = found["accounts"] as! Dictionary<String, Any>

				if account["password"] is String? {
					if account ["password"] as! String == l_pass {
						return rtrue
					}
				}else {
				//debugd = (account["password"] { as! Swift.Array<Swift.String>)
							for a in account["password"] as! Swift.Array<Swift.String>{
								if a == l_pass {
									return rtrue
								}
							}
				}
				return rfalse
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


		if let userName = request.urlVariables["username"] {

			do {
		    try response.setBody(json: dic.getUser(user:userName))
	    	response.setHeader(.contentType, value: "application/json")
	    	response.completed()
			}
			catch {
	        response.setBody(string: "Error handling request: \(error)")
	        response.completed()
	    }
    }


    response.completed()
})
routes.add(method: .get, uri: "/json/login/{username}/{password}", handler: {
    request, response in


		if let userName = request.urlVariables["username"] , let userPass = request.urlVariables["password"]{

			do {
		    try response.setBody(json: dic.userLogin(l_user:userName,l_pass:userPass))
				//try response.setBody(json: ["c-k": dic.debug_out])
	    	response.setHeader(.contentType, value: "application/json")
	    	response.completed()
			}
			catch {
	        response.setBody(string: "Error handling request: \(error)")
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
