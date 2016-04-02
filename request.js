var request = require('request');
var cheerio = require('cheerio');
var json2csv = require('json2csv');
var fs = require('fs');

var partySupport = {
  'SDP': [],
  'VAS': [],
  'KOK': [],
  'KESK': [],
  'RKP': [],
  'KD': [],
  'VIHR': [],
  'PERUSS': [],
  'MUU': []
};

getYearlyData(2014);

function getYearlyData(year) {
  request(getUrl(year), function (error, response, body) {
    if (!error && response.statusCode == 200) {
      parseHtml(body, year);
      exportCsv(partySupport);
    }
  });
}

function getUrl(year) {
  return 'http://www.taloustutkimus.fi/tuotteet_ja_palvelut/puolueiden_kannatusarviot/puolueiden-kannatusarviot-' + year;
}

function parseHtml(body, year) {
  $ = cheerio.load(body);
  $('.content-container table tr').slice(2).each(function (index, element) {
    var td = $(element).children('td');
    var partyName = td.eq(0).text();
    td.slice(3).each(function (index, element) {
      partySupport[partyName].push({
        'date': year + '-' + (index + 1),
        'support': $(element).text().trim().replace(',', '.'),
      });
    });
  });
}

function exportCsv() {
  var fields = ['date'].concat(Object.keys(partySupport));
  var csvData = [];

  var dateData = {};
  for (var i = 0; i < partySupport['SDP'].length; i++) {
    dateData[partySupport['SDP'][i].date] = {};
  }

  for (var partyName in partySupport) {
    supportData = partySupport[partyName];
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