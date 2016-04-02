var request = require('request');
var cheerio = require('cheerio');
var url = 'http://www.taloustutkimus.fi/tuotteet_ja_palvelut/puolueiden_kannatusarviot/puolueiden-kannatusarviot-2015';

request(url, function (error, response, body) {
  if ( ! error && response.statusCode == 200) {
    $ = cheerio.load(body);
    console.log($('h1.pageTitle').text());
  }
});