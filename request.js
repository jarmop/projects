var request = require('request');
var cheerio = require('cheerio');
var json2csv = require('json2csv');
var fs = require('fs');

/**
 * example content {
 *    SDP: [
 *      {
 *      'date': '2015-1',
 *      'support' : 15.2
 *      },
 *      {
 *      'date': '2015-1',
 *      'support' : 15.2
 *      }
 *    ]
 *  }
 */
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

var startYear = 2000;
var endYear = 2016;
var endColAmount = 1;

getYearlyData(startYear);

function getYearlyData(year) {
  request(getUrl(year), function (error, response, body) {
    if (!error && response.statusCode == 200) {
      parseHtml(body, year);
      if (year >= endYear) {
        exportCsv(partySupport);
      } else {
        getYearlyData(year + 1)
      }
    }
  });
}

function getUrl(year) {
  var url = 'http://www.taloustutkimus.fi/tuotteet_ja_palvelut/puolueiden_kannatusarviot/puolueiden-kannatusarviot-' + year;
  if (year < 2011) {
    url = url.replace(/-/g, '_');
  }
  return url;
}

function parseHtml(body, year) {
  $ = cheerio.load(body);
  var partyAmount = 9;
  if (year < 2002) {
    partyAmount = 10;
  }
  $('.content-container table tr').slice(2, partyAmount + 2).each(function (index, element) {
    var td = $(element).children('td');
    var partyName = td.eq(0).text();
    if (year < 2002) {
      if (partyName.indexOf('REM') > -1) {
        // skip Remonttiryhmä
        return true;
      }
      if (partyName === 'SKL/KD' || partyName === 'SKL') {
        partyName = 'KD';
      }
    }
    var sliceStart = 3;
    if (year < 2004) {
      sliceStart = 1;
    }
    var colAmount = 12;
    if (year == 2009) {
      colAmount = 14;
    }
    var sliceEnd = sliceStart + colAmount + 1;
    if (year == endYear) {
      sliceEnd = sliceStart + endColAmount
    };
    var month = 1;
    td.slice(sliceStart, sliceEnd).each(function (index, element) {
      var support = parseFloat($(element).text().trim().replace(',', '.'));
      if (year == 2009 && (index == 1 || index == 4)) {
        month--;
        var data = partySupport[partyName][partySupport[partyName].length - 1];
        data.date = year + '-' + (month);
        data.support = parseFloat(((data.support + support) / 2).toFixed(1));
      } else {
        partySupport[partyName].push({
          'date': year + '-' + (month),
          'support': parseFloat($(element).text().trim().replace(',', '.'))
        });
      }
      month++;
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
    var supportData = partySupport[partyName];
    for (var i = 0; i < supportData.length; i++) {
      dateData[supportData[i].date][partyName] = supportData[i].support;
    }
  }

  for (var date in dateData) {
    var csvDataRow = {'date': date};
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

function estimateMissingValue(data, index) {
  var prev = 0;
  for (var i=index; i>=0; i--) {
    if (data[i].support) {
      prev = data[i].support;
      break;
    }
  }

  var next = 0;
  for (var i=index; i<data.length; i++) {
    if (data[i].support) {
      next = data[i].support;
      break;
    }
  }

  return parseFloat(((prev + next) / 2).toFixed(1));
}