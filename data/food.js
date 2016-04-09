var fs = require('fs');
var request = require('request');

var data = [];

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
  for (var i=0; i<titles.length; i++) {
    // console.log(names[i]);
    data.push({
      'name': titles[i].replace(/[^\s]*$/, '').trim(),
      'unit': titles[i].match(/[^\(]*$/)[0].replace(')', '')
    });
  }
  // process.exit();
}

function parseValues(values) {
  for (var i=0; i<values.length; i++) {
    data[i].value = parseFloat(values[i].replace(' ', '').replace(',','.'));
  }
}

function getValues(line) {
  var names = line.split(';');
  names.splice(0,2);
  return names;
}

function saveJson() {
  fs.writeFile('soybean.json', JSON.stringify(data, null, 4), function(err) {
    if (err) throw err;
    console.log('JSON file saved!');
  });
};