fs = require 'fs'
decompress = require 'decompress-zip'
# decompress = require 'decompress'

###
# copyFile
# ====
# Asynchronuously copy a file to a chosen destination.
# @param src (string):                      Path to the file
# @param dst (string):                      Destination
# @param callback (Function(Error):null):   Callback
###
module.exports.copyFile = (src, dst, callback) ->
    cbCalled = false
  
    done = (err) ->
        if not cbCalled
            callback err
            cbCalled = true

    rd = fs.createReadStream src
    rd.on "error", (err) -> done err

    wr = fs.createWriteStream dst
    wr.on "error", (err) -> done err
    wr.on "close", (ex) -> done null
  
    rd.pipe wr


###
# decompress
# ====
# Asynchronuously decompress an archive.
# @param src (string):                      Path to the archive
# @param dst (string):                      Destination
# @param ext (string):                      Archive extension
# @param callback (Function(Error):null):   Callback
###
module.exports.decompress = (src, dst, ext, callback) ->
    
    if ext == '.zip'
        unzipper = new decompress(src)

        unzipper.on 'error', (err) ->
            console.log "DRIVER - ERR: " + err
            callback err
        
        unzipper.on 'extract', (log) ->
            callback null
        
        unzipper.extract path: dst
    
    else
        callback 'Unsupported format'

    # unzipper = new decompress()
    #  .src src
    #  .dest dst

    # if ext == '.zip'
    #     unzipper.use decompress.zip strip: 1
    # else if  ext == '.tar'
    #     unzipper.use decompress.tar strip: 1
    # else if  ext == '.tar.bz2'
    #     unzipper.use decompress.tarbz2 strip: 1
    # else if  ext == '.tar.gz'
    #     unzipper.use decompress.targz strip: 1

    # unzipper.run (err, files) ->
    #     callback err