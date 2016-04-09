var fs = require('fs');
var request = require('request');

var data = [];

// broileri jauheliha
// request('https://fineli.fi/fineli/fi/elintarvikkeet/28930/resultset.csv', function (error, response, body) {
// kaurahiutale
request('https://fineli.fi/fineli/fi/elintarvikkeet/153/resultset.csv', function (error, response, body) {
// banaani
// request('https://fineli.fi/fineli/fi/elintarvikkeet/28934/resultset.csv', function (error, response, body) {
// soijapapu
// request('https://fineli.fi/fineli/fi/elintarvikkeet/391/resultset.csv', function (error, response, body) {
  if (!error && response.statusCode == 200) {
    var lines = body.split('\r\n');
    parseValues(lines[1].split(';'));
    saveJson(data);
  }
});

function parseValues(values) {
  var counter = 0;
  for (var i in mapNutrientIdToCsvIndex) {
    data.push({
      'nutrientId': parseInt(i),
      'amount': parseFloat(values[mapNutrientIdToCsvIndex[i]].replace(' ', '').replace(',','.'))
    });
    counter++;
  }
}

var mapNutrientIdToCsvIndex = {
  1: 52,
  2: 54,
  3: 55,
  4: 49,
  5: 48,
  6: 46,
  8: 44,
  9: 50,
  10: 51,
  11: 33,
  12: 40,
  13: 36,
  14: 37,
  15: 34,
  16: 42,
  18: 35,
  19: 41
};

function saveJson() {
  fs.writeFile('soybean.json', JSON.stringify(data, null, 4), function(err) {
    if (err) throw err;
    console.log('JSON file saved!');
  });
};