import {WebScraper} from "./web-scraper";
import {Food, FoodNutrient} from "./food-model";
import Firebase = require('firebase');

class Main {
  private webScraper = new WebScraper;
  private firebase = new Firebase("https://nutrient.firebaseio.com/");

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

  updateFood() {
    let id = 391;
    this.webScraper.getNutrients(id).then((nutrients) => {
      this.saveFood(this.getFoodModel(391, nutrients));
      process.exit();
    });
  }

  private getFoodModel(id:number, nutrients:Array<FoodNutrient>): Food {
      return {
          'id': id,
          'name': this.getNameById(id),
          'nutrients': nutrients
      };
  }
  
  private getNameById(id:number): string {
      return this.fineliFoods.find(food => food.id == id).name;
  }

  private saveFood(food: Food) {
    console.log('save to firebase');
    console.log(food);
    this.firebase.set(food);
  }
}

(new Main()).updateFood();