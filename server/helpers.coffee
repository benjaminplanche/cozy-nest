fs = require 'fs'


module.exports.copyFile = (source, target, cb) ->
    cbCalled = false
  
    done = (err) ->
        if not cbCalled
            cb err
            cbCalled = true

    rd = fs.createReadStream source
    rd.on "error", (err) -> done err

    wr = fs.createWriteStream target
    wr.on "error", (err) -> done err
    wr.on "close", (ex) -> done null
  
    rd.pipe wr