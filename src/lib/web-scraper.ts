import request = require('request-promise');
import {FoodNutrient} from "./food-model";

export class WebScraper {
  private mapNutrientIdToCsvIndex = {
    '-KGVgcdCZmbVXLHZRkrX': 52,
    '-KGVgd4rwRG18j1CO-Ep': 54,
    '-KGVgd71cV38Lt-tYyrA': 55,
    '-KGVgd9DTW6MOL2DXkSj': 49,
    '-KGVgdBP00KTfT8nLmTt': 48,
    '-KGVgdDc035sNQQo_TUq': 46,
    '-KGVgdFnsVdVfyEEG37i': 44,
    '-KGVgdHzLAdtSu0bAOOf': 50,
    '-KGVgdKAvBda89ht5oTk': 51,
    '-KGVgdMLHl7HL_FtD1We': 33,
    '-KGVgdOWSGfdw1idtOb2': 40,
    '-KGVgdQipHYexWY5FLLv': 36,
    '-KGVgdSujck0WYhAkN6G': 37,
    '-KGVgdV7M4SUf9UhBVHA': 34,
    '-KGVgdXIpnMl5DmYLoZ5': 42,
    '-KGVgdZV7oPYN2FTtqG5': 35,
    '-KGVgdaiYWiaaH7sOnhE': 41
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
    for (let nutrientId of Object.keys(this.mapNutrientIdToCsvIndex)) {
      nutrients.push({
        'nutrientId': nutrientId,
        'amount': parseFloat(values[this.mapNutrientIdToCsvIndex[nutrientId]].replace(' ', '').replace(',', '.'))
      });
      counter++;
    }
    return nutrients;
  }

}