import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

class Dic{
	init(){
		self.debugd = ["":""]
		self.debug = ""
	}

	var names = ["usernames":[
	    ["email":"c@d.com", "username":"cbcdiver", "password":"pencil99"],
	    ["email":"a@b.com", "username":"dogs", "password":["pencil99","groundhog"]]
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
			if let account = found["accounts"] as! Dictionary<String, Any>? {
				if account["password"] is String? {
					if account ["password"] as! String == l_pass {
						return rtrue
					}
				}else {
					for a in account["password"] as! Swift.Array<Swift.String>{
						if a == l_pass {
							return rtrue
						}
					}
				}
			}
			return rfalse
	 }
	 func userAdd(add_user:String,add_pass:String,add_email:String) -> Dictionary<String, Any>{
				let found = getUser(user:add_user)
				if let account = found["result"] as! String? {
						names["usernames"]?.append(["email":add_email, "username":add_user, "password":add_pass])
						return rtrue
				}
				return rfalse
		}

		func change(change_user:String = "",change_pass:String = "",change_email:String = "",change_newuser:String = "") -> Dictionary<String, Any>{
				let found = getUser(user:change_user)
				if let account = found["accounts"] as! Dictionary<String, Any>? {

					if change_user != "" {
						if change_pass != "" {
							return account;
						}
						if change_email != ""{
							return account;
						}
						if change_newuser != ""{
							return account;

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

routes.add(method: .get, uri: "/json/all",handler: {
    request, response in
    do {
        try response.setBody(json: dic.names)
            response.setHeader(.contentType, value: "application/json")
            response.completed()

    } catch {
        response.setBody(string: "Error handling request: \(error)")
        response.completed()
    }
})
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


		if let userName = request.urlVariables["username"],let userPass = request.urlVariables["password"] {


				do {
			    try response.setBody(json: dic.userLogin(l_user:userName,l_pass:userPass))
					//try response.setBody(json: ["c-k": dic.names])
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
routes.add(method: .post, uri: "/json/add", handler: {
    request, response in
		let username = request.param(name: "username")
    let userpass = request.param(name: "password")
		let useremail = request.param(name: "email")
    // We need to check for missing fields, so, let us keep an array of the names
    // of the fields which are missing
    var missingFields = [String]()

		if username == nil {
        missingFields.append("UserName")
    }
    if  userpass == nil  {
        missingFields.append("Password")
    }
		if  useremail == nil  {
        missingFields.append("Email")
    }

		if missingFields.count > 0 {
				do {
						try response.setBody(json: ["Result":"The following field(s) are missing: " +
								missingFields.joined(separator: ", ")])
						response.setHeader(.contentType, value: "application/json")
						response.completed()
				} catch {
						response.setBody(string: "Error Generating JSON response: \(error)")
						response.completed()
				}
				return
		}
		else {
			do {
				try response.setBody(json: dic.userAdd(add_user:username!,add_pass:userpass!,add_email:useremail!))
				//try response.setBody(json: dic.names)
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

routes.add(method: .put, uris: ["/json/change_password","/json/change_username","/json/change_email"], handler: {
    request, response in
		let username = request.param(name: "username")
		let usernewname = request.param(name: "newuser")
    let userpass = request.param(name: "password")
		let useremail = request.param(name: "email")
    // We need to check for missing fields, so, let us keep an array of the names
    // of the fields which are missing

    response.completed()
})

server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
