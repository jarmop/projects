var fs = require('fs');
var lineReader = require('readline').createInterface({
  input: fs.createReadStream('recommendations.csv', {'start' : 51})
});

var data = [];
lineReader.on('line', function (line) {
  var cols = line.split(',');
  data.push({
    'name' : cols[0].split(' ')[0],
    'male' : cols[1],
    'female' : cols[2],
    'max' : cols[3],
    'nutrientDensity' : cols[4],
    'unit' : cols[0].split(' ')[1]
  });
});

lineReader.on('close', function (line) {
  fs.writeFile('recommendations.json', JSON.stringify(data, null, 4), function(err) {
    if (err) throw err;
    console.log('JSON file saved!');
  });
});