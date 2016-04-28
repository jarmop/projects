import {WebScraper} from "./web-scraper";
import {FirebaseAdapter} from "./adapter/firebase.adapter";
import {Food, FoodNutrient} from "./food-model";

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

  addFood(id:number) {
    return this.webScraper.getNutrients(id).then((nutrients) => {
      return this.firebase.saveFood(this.getFoodModel(391, nutrients));
    });
  }

  private getFoodModel(id:number, nutrients:Array<FoodNutrient>):Food {
    return {
      "fineliId": id,
      'name': this.getNameById(id),
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
  (new FoodProcessor()).addFood(391).then(finish('Added food!'));
}