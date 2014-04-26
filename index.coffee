PersonController = require 'members-area/app/controllers/person'

module.exports =
    initialize: (done) ->
        @app.addRoute 'all' , '/rfidcodes' , 'members-area-rfid-codes#rfid-codes#list'
        @hook 'render-person-view' , @modifyUserPage.bind(this)
        @hook 'models:initialize', @modifyUserModel.bind(this)
        PersonController.before @processRfid, only: ['view']
        done()
             
    modifyUserPage: (options, done) ->
        {controller, html} = options

        #Get meta for currently selected user (not request user)
        codes = controller.user.rfidcodes
        #TODO: Security - who is allowed to delete codes? 
        lis = ("<li><form method='POST'><input type='hidden' name='deleteRfid' value='y'>
                <input type='hidden' name ='code' value='#{code}'>#{code}
                <input type='submit' value='X'></form></li>" for code in codes)

        #TODO: Security - who is allowed to add codes? 
        htmlToAdd = "<form method='POST'><input type=text name='rfid'>"
        htmlToAdd += "<input type='hidden' name='addNewRfid' value='rfid'>"
        htmlToAdd += "<input type='submit'value='Add'></form>"
        if lis.length
            htmlToAdd += '<ul>'+lis.join('')+'</ul>'
        options.html = html.replace("</h2><p>", "</h2>"+htmlToAdd+"<p>")

        done()

    processRfid: (done) ->
      #this code runs in the context of the person controller instance, NOT this plugin
      #TODO: Security? Do we need to check the user is allowed to call us?
      if @req.method is 'POST' and @req.body.addNewRfid
        @user.addRfidCode(@req.body.rfid)
        @user.save done
      else if @req.method is 'POST' and @req.body.deleteRfid
        @user.deleteRfidCode(@req.body.code)
        @user.save done
      else
        done()

    modifyUserModel: (options) ->
      options.models.User.instanceProperties.rfidcodes = 
        get: -> 
          @meta.rfidcodes ? []
      options.models.User.instanceMethods.addRfidCode = (newCode) -> 
          @rfidcodes.push(newCode) unless @rfidcodes.indexOf(newCode) >= 0
          @setMeta rfidcodes: @rfidcodes
      options.models.User.instanceMethods.deleteRfidCode = (code) -> 
          @rfidcodes.splice(@rfidcodes.indexOf(code),1)
          @setMeta rfidcodes: @rfidcodes

