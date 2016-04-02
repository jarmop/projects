var request = require('request');
var cheerio = require('cheerio');
var json2csv = require('json2csv');
var fs = require('fs');
var url = 'http://www.taloustutkimus.fi/tuotteet_ja_palvelut/puolueiden_kannatusarviot/puolueiden-kannatusarviot-2015';

var partySupport = {
  'SDP': [],
  'VAS': []
};
request(url, function (error, response, body) {
  if (!error && response.statusCode == 200) {
    $ = cheerio.load(body);
    $('.content-container table.MsoNormalTable tr').slice(2,4).each(function (index, element) {
      var td = $(element).children('td');
      var partyName = td.eq(0).text();
      td.slice(3,5).each(function (index, element) {
        partySupport[partyName].push({
          'date': '2015-' + (index + 1),
          'support': $(element).text().replace(',', '.'),
        });
      });
    });

    exportCsv(partySupport);
  }
});

function exportCsv(data) {
  var fields = ['date', 'SDP', 'VAS'];
  var csvData = [];

  var dateData = {
    '2015-1': {},
    '2015-2': {}
  };

  for (var partyName in data) {
    supportData = data[partyName];
    for (var i = 0; i < supportData.length; i++) {
      dateData[supportData[i].date][partyName] = supportData[i].support;
    }
  }

  for (var date in dateData) {
    var csvDataRow = {'date' :date};
    for (var i in dateData[date]) {
      csvDataRow[i] = dateData[date][i];
    }
    csvData.push(csvDataRow);
  }
  
  json2csv({ data: csvData, fields: fields }, function(err, csv) {
    if (err) console.log(err);
    fs.writeFile('party-support.csv', csv, function(err) {
      if (err) throw err;
      console.log('file saved');
    });
  });
}