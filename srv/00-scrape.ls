require! {
  request
  fs
}

roky =
  [1 2005]
  [2 2006]
  [3 2007]
  [4 2008]
  [5 2009]
  ['5a' 2010]
  [6 2011]
  [7 2012]
  [8 2013]
for let [id, rok] in roky
  form =
    rck: id
    tab: 'D1.1.7.1'
  (err, data, body) <~ request.post 'http://toiler.uiv.cz/rocenka/rocenka.asp', {form}
  <~ fs.writeFile "#__dirname/../data/raw/#rok.html", body
