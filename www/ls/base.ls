container = d3.select ig.containers.base
data = d3.tsv.parse ig.data.jazyky, (row) ->
  for field in <[rok celkem anglictina francouzstina nemcina rustina spanelstina italstina latina rectina evropsky jiny]>
    row[field] = parseInt row[field], 10
  if row.nuts == "CZ061" then row.nuts = "CZ063"
  if row.nuts == "CZ062" then row.nuts = "CZ064"
  row

nuts =
  "CZ0":   name: "Česká republika", data: [], lines: {}
  "CZ010": name: "Hlavní město Praha", data: [], lines: {}
  "CZ020": name: "Středočeský kraj", data: [], lines: {}
  "CZ031": name: "Jihočeský kraj", data: [], lines: {}
  "CZ032": name: "Plzeňský kraj", data: [], lines: {}
  "CZ041": name: "Karlovarský kraj", data: [], lines: {}
  "CZ042": name: "Ústecký kraj", data: [], lines: {}
  "CZ051": name: "Liberecký kraj", data: [], lines: {}
  "CZ052": name: "Královéhradecký kraj", data: [], lines: {}
  "CZ053": name: "Pardubický kraj", data: [], lines: {}
  "CZ063": name: "Kraj Vysočina", data: [], lines: {}
  "CZ064": name: "Jihomoravský kraj", data: [], lines: {}
  "CZ071": name: "Olomoucký kraj", data: [], lines: {}
  "CZ072": name: "Zlínský kraj", data: [], lines: {}
  "CZ080": name: "Moravskoslezský kraj", data: [], lines: {}

jazyky =  <[anglictina francouzstina nemcina rustina spanelstina italstina latina rectina evropsky jiny]>
jazyky_h =
  anglictina    : "angličtina"
  francouzstina : "francouzština"
  nemcina       : "němčina"
  rustina       : "ruština"
  spanelstina   : "španělština"
  italstina     : "italština"
  latina        : "klasická latina"
  rectina       : "řečtina"
  evropsky      : "jiné evropské jazyky"
  jiny          : "ostatní jazyky"

years = [2006 to 2013].map -> "#it/#{it + 1}"

for code, nutsData of nuts
  for jazyk in (jazyky ++ ['celkem'])
    nutsData.lines[jazyk] = [jazyky_h[jazyk]]


for line in data
  nutsData = nuts[line.nuts]
  nutsData.data.push line
  for jazyk in jazyky
    nutsData.lines[jazyk].push line[jazyk] / line['celkem']
  nutsData.lines['celkem'].push line['celkem']

selectorsContainer = container.append \div
  ..attr \class \selectors
container.append \div .attr \id \chart
chart = c3.generate do
  bindto: \#chart
  data:
    columns: []
  axis:
    y:
      min: 0
      max: 1
      padding:
        top:0
        bottom:0
      tick:
        format: ->
          p = it * 100
          "#{p} %"
    x:
      tick:
        format: -> years[it]
  tooltip:
    format:
      value: (value, _, __, i) ->
        console.log currentNuts.lines
        number = ig.utils.formatNumber value * currentNuts.lines.celkem[i + 1]
        "#{ig.utils.formatNumber value * 100 1} % (#number studentů)"

currentNuts = null
drawNuts = (nuts = currentNuts) ->
  currentNuts := nuts
  columns = displayedJazyky.map -> nuts.lines[it]
  chart.load {columns}

removeJazyk = (jazyk) ->
  chart.unload ids: [jazyky_h[jazyk]]

addJazyk = (jazyk) ->
  columns = [currentNuts.lines[jazyk]]
  chart.load {columns}

displayedJazyky = <[anglictina nemcina]>

drawNuts nuts.CZ0

selectorsContainer
  ..append "h2" .html "Zobrazené jazyky: "
  ..append \ul
    ..selectAll \li .data jazyky .enter!append \li
      ..append \input
        ..attr \type \checkbox
        ..attr \checked -> if it in displayedJazyky then "checked" else void
        ..attr \id -> "jaz-#it"
        ..on \change ->
          index = displayedJazyky.indexOf it
          if index == -1
            displayedJazyky.push it
            addJazyk it
            @checked = yes
          else
            displayedJazyky.splice index, 1
            removeJazyk it
            @checked = no
      ..append \label
        ..attr \for -> "jaz-#it"
        ..html -> jazyky_h[it]

nuts_array = for code, contents of nuts
  contents.code = code
  contents

selectorsContainer
  ..append "h2" .html "Zobrazený kraj: "
  ..append \ul
    ..selectAll \li .data nuts_array .enter!append \li
      ..append \input
        ..attr \type \radio
        ..attr \checked -> if it is currentNuts then "checked" else void
        ..attr \id -> "nuts-#{it.code}"
        ..attr \name \nuts
        ..on \change -> drawNuts it
      ..append \label
        ..attr \for -> "nuts-#{it.code}"
        ..html -> it.name

