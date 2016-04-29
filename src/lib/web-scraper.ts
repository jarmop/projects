import request = require('request-promise');
import {FoodNutrient} from "./food-model";

export class WebScraper {
  private mapNutrientIdToCsvIndex = {
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

  /**
   * @param foodId
   * @returns {Promise<Array<FoodNutrient>>|PromiseLike<Array<FoodNutrient>>}
   */
  public getNutrients(foodId) {
    console.log(this.getUrl(foodId));
    return request(this.getUrl(foodId)).then((body) => {
      console.log(body);
      return this.parseNutrients(body);
    }).catch((error) => {
      console.log(error);
    });

  }

  private getUrl(fooddId) {
    // return 'https://fineli.fi/fineli/fi/elintarvikkeet/' + fooddId + '/resultset.csv';
    return 'http://localhost:8080/soybean.csv';
  }

  parseNutrients(body):Array<FoodNutrient> {
    var lines = body.split('\r\n');
    var values = lines[1].split(';');
    var nutrients = [];
    var counter = 0;
    for (var i in this.mapNutrientIdToCsvIndex) {
      nutrients.push({
        'nutrientId': parseInt(i),
        'amount': parseFloat(values[this.mapNutrientIdToCsvIndex[i]].replace(' ', '').replace(',', '.'))
      });
      counter++;
    }
    return nutrients;
  }

}