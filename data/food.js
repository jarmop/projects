var fs = require('fs');
var request = require('request');

var data = [];



// request('https://fineli.fi/fineli/fi/elintarvikkeet/28930/resultset.csv', function (error, response, body) {
// request('https://fineli.fi/fineli/fi/elintarvikkeet/153/resultset.csv', function (error, response, body) {
request('https://fineli.fi/fineli/fi/elintarvikkeet/391/resultset.csv', function (error, response, body) {
  if (!error && response.statusCode == 200) {
    var lines = body.split('\r\n');
    parseNamesAndUnit(getValues(lines[0]));
    parseValues(getValues(lines[1]));
    // console.log(data);
    saveJson(data);
  }
});

function parseNamesAndUnit(titles) {
  // i = 44;
  for (var i in mapNutrientIdToCsvIndex) {
    // console.log(names[i]);
    data.push({
      'nutrientId': parseInt(i),
      'name': titles[mapNutrientIdToCsvIndex[i]].replace(/[^\s]*$/, '').trim(),
      'unit': titles[mapNutrientIdToCsvIndex[i]].match(/[^\(]*$/)[0].replace(')', '')
    });
  }
  // console.log(data);
  // process.exit();
}

function parseValues(values) {
  // for (var i=0; i<values.length; i++) {
  var counter = 0;
  for (var i in mapNutrientIdToCsvIndex) {
    data[counter].value = parseFloat(values[mapNutrientIdToCsvIndex[i]].replace(' ', '').replace(',','.'));
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

function getValues(line) {
  var values = line.split(';');
  // for (var i=0; i<values.length; i++) {
    // console.log(i + ': ' + values[i]);
  // }

  // var returnValues = [];
  // for (var i in mapNutrientIdToCsvIndex) {
  //   returnValues.push(values[mapNutrientIdToCsvIndex[i]]);
  // }
  // values.splice(0,3);
  // values.splice(3,27);
  // values.splice(9,1);
  // values.splice(12,1);
  // values.splice(13,1);
  // values.splice(14,1);
  // values.splice(-4,1);
  // values.splice(-1,1);
  return values;
}

function saveJson() {
  fs.writeFile('soybean.json', JSON.stringify(data, null, 4), function(err) {
    if (err) throw err;
    console.log('JSON file saved!');
  });
};