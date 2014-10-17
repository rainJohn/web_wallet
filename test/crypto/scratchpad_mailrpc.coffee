console.log "-------------------"
PORT=process.argv[2] or 2211
console.log "(param 1) PORT",PORT

{Common} = require "./rpc_common"
{Rpc} = require "./rpc_json"
@rpc=new Rpc(on, PORT, "localhost", "test", "test")
@common=new Common(@rpc)


class Mail
    constructor: (@rpc, @common) ->

    send: (
        from = "tester"
        to = "tester"
        subject = "The Subject"
        body = "Body..."
    ) ->
        @rpc.request("mail_send", [from, to, subject, body]).then (response) ->
            @message_id = response
            console.log "Submitted Message ID",message_id

    check: ->
        @rpc.request("mail_get_processing_messages").then (response) ->
            for x in response
                if x[1] == @message_id
                    console.log "check (status) ", x[0]

    processing_cancel_all: ->
        #https://github.com/BitShares/bitshares_toolkit/commit/57d04e8fb2b0dda15623e83a6855f77b2dc1cbd6
        #mail_cancel_message id
        @rpc.request("mail_get_processing_messages").then (response) ->
            for x in response
                @common.run("mail_cancel_message #{x[1]}")

class MailTest
    
    constructor: (@rpc, @common) ->
        @mail=new Mail(@rpc, @common)
    
    clear: ->
        @mail.processing_cancel_all()
    
    send: ->
        @mail.send "tester", "tester", "subject", 
            #
            # Send a message long enough to require a multi-byte
            # length prefix (longer than 256)
            #
            """
            What have you seen?
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            end of transmission
            """
    box: ->
        @rpc.run "mail_inbox"

    processing: =>
        @rpc.request("mail_get_processing_messages").then (response) ->
            for x in response
                console.log "processing_message", x

    shut: ->
        @mail.check()
        @rpc.close()


class TestNet
    INVICTUS_ROOT=process.env.INVICTUS_ROOT
    
    constructor: (@common, @rpc) ->
        
    unlock: ->
        @rpc.request(
            "open default"
            "unlock 9999 Password00"
        )

    default: ->
        @rpc.request("default", "9999", "Password00")
###
wallet_create default Password00
open default
unlock 9999 Password00
wallet_import_private_key 5K1poDmFzYXd3Eyfuk4DR2jZbHuanzJdmTbxjNPKcrLzeS7EFDS tester true true
wallet_import_private_key 5JURMQGrUigepksfuRNd2z4gHuX3X1Gy6wfn6DJYG5yKm4uQUWQ init0 true

wallet_list_accounts
mail_send tester tester subject body
mail_get_processing_messages

## block production must be enabled
register tester tester "" -1 "titan_account"

###

TestNetTest = ->
    
    #tn=new TestNet(@rpc, @common)
    #tn.default()
    
    ## vi tmp/client_p8I/config.json  # "mail_server_enabled": true,
    ## web_wallet/test/testnet$ RPC_PORT=3000 ./client.sh tmp/client_p8I
    ## web_wallet/test/crypto$ coffee -w scratchpad_mail.coffee 3000
    m=new MailTest(@rpc, @common)
    #m.send()
    @rpc.request "mail_check_new_messages"
    #m.clear()
    m.processing()
    m.box()


@rpc.close()
