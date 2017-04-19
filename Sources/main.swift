import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

class Dic{

	var names = ["usernames":[
	    ["email":"c@d.com", "username":"cbcdiver", "password":"pencil99"],
	    ["email":"a@b.com", "username":"dogs", "password":"groundhog"]
	]]
	let notfound = ["result":"no account"]
	let rtrue = ["result":"true"]
	let rfalse = ["result":"false"]

	func checkUsernames(user:String) -> Bool {
			if user.lowercased() != user {
				return true
			}
			return false
	}
	func checkEmails(user:String) -> Bool {
			let email_regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}" as! CVarArg
      let emailTest = NSPredicate(format:"SELF MATCHES %@", email_regex)
      return emailTest.evaluate(with: user)
	}

	 func getUser(user:String) -> Dictionary<String, Any>{
				for (accounts) in names["usernames"]! {
					if user == accounts["username"]! {
						return ["accounts":accounts]
					}
				}
				return notfound
   }
	 func userLogin(l_user:String,l_pass:String) -> Dictionary<String, Any>{
			let found = getUser(user:l_user)
			if let account = found["accounts"] as! Dictionary<String, Any>? {
					if account ["password"] as! String == l_pass {
						return rtrue
					}
				}
			return rfalse
	 }
	 func userAdd(add_user:String,add_pass:String,add_email:String) -> Dictionary<String, Any>{
				let found = getUser(user:add_user)
				if found["result"] != nil {
						names["usernames"]?.append(["email":add_email, "username":add_user, "password":add_pass])
						return rtrue
				}
				return rfalse
		}
		func delete(delete_user:String) -> Dictionary<String, Any>{
			let found = getUser(user:delete_user)
			if found["accounts"] != nil {
					for i in 0...names.count {
						if delete_user == names["usernames"]![i]["username"]{
								names["usernames"]!.remove(at: i)
							 return rtrue
						 }
				 }
			 }
				 return rfalse
		 }
		func change(change_user:String = "",change_pass:String = "",change_email:String = "",change_newuser:String = "") -> Dictionary<String, Any>{

				if change_user != "" {
					for i in 0...names.count {
						if change_user == names["usernames"]![i]["username"]{
							if change_pass != "" {
								names["usernames"]![i]["password"] = change_pass
								return rtrue;
							}
							if change_email != ""{
								names["usernames"]![i]["email"] = change_email
								return rtrue;
							}
							if change_newuser != ""{
								names["usernames"]![i]["user"] = change_newuser
								return rtrue;
							}
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
    print("/n************")
    print(username)
    print(userpass)
    print(useremail)
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
		do {
			if username != nil {
					if useremail != nil {
						try response.setBody(json: dic.change(change_user:username!,change_email:useremail!))
					}
					else if userpass != nil {
	
                        try response.setBody(json: dic.change(change_user:username!,change_pass:userpass!))
					}
					else if usernewname != nil{
						try response.setBody(json: dic.change(change_user:username!,change_newuser:usernewname!))
					}
			}//try response.setBody(json: ["c-k": dic.names])
			response.setHeader(.contentType, value: "application/json")
			response.completed()
		}
		catch {
				response.setBody(string: "Error handling request: \(error)")
				response.completed()
		}

    response.completed()
})

routes.add(method: .delete, uri: "/json/delete/{username}", handler: {
    request, response in
		if let userName = request.urlVariables["username"]{
				do {
			    try response.setBody(json: dic.delete(delete_user:userName))
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


server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
