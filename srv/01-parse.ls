require! {
  fs
  jsdom.env
  jquery
  async
}

(err, files) <~ fs.readdir "#__dirname/../data/raw"

years = {}
names = <[celkem anglictina francouzstina nemcina rustina spanelstina italstina latina rectina evropsky jiny ]>
<~ async.eachSeries files, (file, cb) ->
  years[file.split '.' .0] = out = {}
  (err, data) <~ fs.readFile "#__dirname/../data/raw/#file"
  html = data.toString!
  (err, window) <~ env html
  $ = jquery window
  $ 'table.tbl tr' .each ->
    $ele = $ @
    nuts = null
    index = null
    $ele.find 'td' .each (i) ->
      content = @innerHTML
      if 'CZ' == content.substr 0, 2 #and content.length == 5
        nuts := content
        if out[nuts]
          nuts := null
          return
        out[nuts] = {}
        for i in [0 to 10]
          out[nuts][names[i]] = 0
        index := -1
      else if nuts
        index++
        out[nuts][names[index]] += parseInt content, 10
  cb!
# <~ fs.writeFile "#__dirname/../data/scraped.json", JSON.stringify years, 1, 2
l2 = for year, data of years
  l = for nuts, data2 of data
    if nuts.length == 4
      null
    else
      line = for column, value of data2
        value
      "#year\t#nuts\t#{line.join '\t'}"
  l.filter(-> it isnt null).join "\n"
l2.unshift "rok\tnuts\t#{names.join '\t'}"
out = l2.join "\n"
fs.writeFile "#__dirname/../data/data.tsv" out

# lines = for year, {CZ0} of years
#   line = for name, value of CZ0
#     value
#   line.unshift year
#   line.join "\t"
# lines.unshift (['year'] ++ names).join "\t"
# fs.writeFile "#__dirname/../data/years.tsv", lines.join "\n"
