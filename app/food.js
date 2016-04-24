"use strict";
var fs = require('fs');
var request = require('request');
// var csvUrl = 'https://fineli.fi/fineli/fi/elintarvikkeet/' + fineliFoods[0].id + '/resultset.csv';
var csvUrl = 'http://localhost:8080/soybean.csv';
request(csvUrl, function (error, response, body) {
    if (!error && response.statusCode == 200) {
        var nutrients = parseNutrients(body);
        foodModel.id = 1;
        foodModel.name = 'Soijapapu';
        foodModel.nutrients = nutrients;
        saveJson(foodModel);
    }
});
function parseNutrients(body) {
    var lines = body.split('\r\n');
    var values = lines[1].split(';');
    var nutrients = [];
    var counter = 0;
    for (var i in mapNutrientIdToCsvIndex) {
        nutrients.push({
            'nutrientId': parseInt(i),
            'amount': parseFloat(values[mapNutrientIdToCsvIndex[i]].replace(' ', '').replace(',', '.'))
        });
        counter++;
    }
    return nutrients;
}
function saveJson(data) {
    fs.writeFile('../json/soybean.json', JSON.stringify(data, null, 4), function (err) {
        if (err)
            throw err;
        console.log('JSON file saved!');
    });
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
var fineliFoods = [
    {
        id: 33122,
        name: 'Soijamaito'
    },
    {
        id: 391,
        name: 'Soijapapu'
    },
    {
        id: 29222,
        name: 'Kasvishernekeitto'
    },
    {
        id: 11212,
        name: 'Auringonkukansiemen'
    },
    {
        id: 3343,
        name: 'Kaurahiutale'
    },
    {
        id: 28934,
        name: 'Banaani'
    }
];
var foodModel = {
    'id': 1,
    'name': 'Banaani',
    'nutrients': [
        {
            'nutrientId': 1,
            'amount': 2
        }
    ]
};
//# sourceMappingURL=food.js.map