###
# =================
# CONTROLLERS - Helpers
# =================
# by bnjbvr (https://github.com/bnjbvr/kresus/blob/master/server/controllers/helpers.coffee)
###

module.exports =
	sendErr: (res, msg, errorCode = 500, userMessage = "Internal server error.") ->
		console.error 'Error - ', msg
		res.send errorCode, error: userMessage