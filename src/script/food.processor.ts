import {WebScraper} from "../lib/web-scraper";
import {FirebaseAdapter} from "../lib/adapter/firebase.adapter";
import {Food, FoodNutrient} from "../lib/food-model";

class FoodProcessor {
  private webScraper = new WebScraper;
  private firebase = new FirebaseAdapter;

  private fineliFoods = [
    {
      id: 33122,
      name: 'Soijamaito'
    },
    {
      id: 391,
      name: 'Soijapapu'
    },
    // {
    //   id: 29222,
    //   name: 'Kasvishernekeitto'
    // },
    // {
    //   id: 11212,
    //   name: 'Auringonkukansiemen'
    // },
    // {
    //   id: 3343,
    //   name: 'Kaurahiutale'
    // },
    // {
    //   id: 28934,
    //   name: 'Banaani'
    // }
  ];

  addFood(fineliFood) {
    return this.webScraper.getNutrients(fineliFood.id).then((nutrients) => {
      return this.firebase.saveFood(this.getFoodModel(fineliFood, nutrients));
    });
  }

  async addFoods() {
    for (let fineliFood of this.fineliFoods) {
      await this.addFood(fineliFood);
    }
  }

  private getFoodModel(fineliFood, nutrients:Array<FoodNutrient>):Food {
    return {
      "fineliId": fineliFood.id,
      'name': fineliFood.name,
      'nutrients': nutrients
    };
  }

  private getNameById(id:number):string {
    return this.fineliFoods.find(food => food.id == id).name;
  }

  truncate() {
    return this.firebase.truncateFoods();
  }
}

function finish(message) {
  return function() {
    console.log(message);
    process.exit();
  }
}

let foodProcessor = new FoodProcessor();
if (process.argv.indexOf('truncate') != -1) {
  foodProcessor.truncate().then(finish('Truncated!'));
} else {
  (new FoodProcessor()).addFoods().then(finish('Added foods!'));
}