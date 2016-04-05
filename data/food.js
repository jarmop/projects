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
    // i = 44;
    for (var i=0; i<names.length; i++) {
      console.log(names[i]);
      data.push({
        'name': names[i].replace(/[^\s]*$/, '').trim(),
        'unit': names[i].match(/[^\(]*$/)[0].replace(')', '')
        // 'unit': names[i].match(/\((.*?)\)$/)[1]
        // 'unit': names[i].match(/([.])$/)[0]
        // 'unit': names[i].match(/[^\s]*$/)[0]
      });
      // console.log(names[i].split(' '));
      // console.log(names[i].match(/[\((.*?)\)]$/));
      // console.log(names[i].match(/\(.*?\)/));

      // console.log(names[i].match(/[^\s]*$/)[0].match(/[^\(\)]+/));
      // console.log(names[i].match(/[^\(]*$/)[0].replace(')', ''));


    }
    // process.exit();

  } else {
    var values = line.split(';');
    values.splice(0,2);
    for (var i=0; i<values.length; i++) {
      data[i].value = parseFloat(values[i].replace(' ', '').replace(',','.'));
    }
  }
  counter++;
});

lineReader.on('close', function (line) {
  fs.writeFile('soybean.json', JSON.stringify(data, null, 4), function(err) {
    if (err) throw err;
    console.log('JSON file saved!');
  });
});