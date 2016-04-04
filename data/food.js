var fs = require('fs');
var lineReader = require('readline').createInterface({
  input: fs.createReadStream('soybean.csv'/*, {'start' : 50}*/)
});

var data = [];
var counter = 0;
lineReader.on('line', function (line) {
  if (counter === 0) {
    var names = line.split(';');
    names.splice(0,2);
    for (var i=0; i<names.length; i++) {
      data.push({
        'name': names[i].replace(/[^\s]*$/, '').trim()
      });
    }
  } else {
    var values = line.split(';');
    values.splice(0,2);
    for (var i=0; i<values.length; i++) {
      data[i].value = parseFloat(values[i].replace(' ', '').replace(',','.'));
    }
    // console.log(data);
  }
  counter++;
});

lineReader.on('close', function (line) {
  fs.writeFile('soybean.json', JSON.stringify(data, null, 4), function(err) {
    if (err) throw err;
    console.log('JSON file saved!');
  });
});