var fs = require('fs');
var lineReader = require('readline').createInterface({
  input: fs.createReadStream('recommendations.csv', {'start' : 51})
});

var data = [];
lineReader.on('line', function (line) {
  var cols = line.split(',');
  data.push({
    'name' : cols[0].split(' ')[0],
    'male' : parseFloat(cols[1]),
    'female' : parseFloat(cols[2]),
    'max' : parseFloat(cols[3]),
    'nutrientDensity' : parseFloat(cols[4]),
    'unit' : cols[0].split(' ')[1]
  });
});

lineReader.on('close', function (line) {
  fs.writeFile('recommendations.json', JSON.stringify(data, null, 4), function(err) {
    if (err) throw err;
    console.log('JSON file saved!');
  });
});