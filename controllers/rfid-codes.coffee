Controller = require 'members-area/app/controller'

module.exports = class RfidCodes extends Controller
    list: (done)->
        @rendered = true # We're handling rendering
        #TODO Security! Need to check additional secret here
        if false
            @res.json 400, {errorCode: 400, errorMessage: "Invalid or no auth"}
            return done()
        else
            @req.models.User.find()
            #TODO: Filter to only approved users
            .where("1")
            .run (err, users) =>
                codes = {}
                if(err)
                    @res.json 500, {errorCode: 500, errorMessage: err}
                    console.log err
                    return done(err)
                console.log users[0]
                for u in users
                    if u.meta.rfidcodes
                        for code in u.meta.rfidcodes
                            #might be an existing known code
                            thisCode = codes[code] ? {}

                            #might manage to share an id (so deal with it)
                            if thisCode.username
                               thisCode.username += " and "+u.username 
                               thisCode.fullname += " and "+u.fullname
                            else
                               thisCode.username = u.username
                               thisCode.fullname = u.fullname

                            #get all roles
                            thisCode.roles ?= []
                            #TODO: How do we get what roles this user belongs to
                            #Or do we just want to check for a specific role (canOpenSpace) and send that?

                            #stash back in the json
                            codes[code] = thisCode
                @res.json codes
        return done()
