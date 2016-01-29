# CLI toolのエントリポイント
# mio method arg1 arg2 arg3..

# parse arguments
method = if process.argv[2] then method = process.argv[2].toString() else method = ''
args = process.argv.slice 3

if typeof this[method] is 'function'
    this[method].apply args

return
