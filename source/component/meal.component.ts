import {Component, OnInit} from 'angular2/core';
import {RecommendationService} from '../service/recommendation.service';
import {MealService} from '../service/meal.service';
import {FoodService} from '../service/food.service';
import {NutrientService} from "../service/nutrient.service";
import {MealFoodsComponent} from '../component/meal-foods.component';
import {MealNutrientsComponent} from '../component/meal-nutrients.component';
import {MealFood} from "../model/mealFood";

@Component({
  selector: 'meal',
  templateUrl: 'component/meal.component.html',
  directives: [MealFoodsComponent, MealNutrientsComponent]
})

export class MealComponent implements OnInit {
  mealFoods = [];
  mealNutrients = [];

  private meal;
  private foods;
  private nutrients;
  private recommendations;

  constructor(
    private _recommendationService:RecommendationService,
    private _mealService:MealService,
    private _foodService:FoodService,
    private _nutrientService:NutrientService
  ) {}

  ngOnInit() {
    this._mealService.getMeal(0).then(meal => {
      this.meal = meal;
      let foodIds = [];
      for (let food of meal.foods) {
        foodIds.push(food.foodId)
      }
      this._foodService.getFoods(foodIds).then(foods => {
        this.foods = foods;
        this._nutrientService.getNutrients().then(nutrients => {
          this.nutrients = nutrients;
          this._recommendationService.getRecommendations('-KGaiyy8KagLuplWuw70').then(recommendations => {
            this.recommendations = recommendations.recommendations;
            this.initMealFoods();
            this.initMealNutrients();
          });
        });
      });
    });
  }

  goBack() {
    window.history.back();
  }

  removeMealFood() {
    this.updateMealNutrients();
  }

  saveMealFood(mealFood:MealFood) {
    this.updateFoods(mealFood).then(() => this.updateMealNutrients());
  }

  addMealFood(mealFood:MealFood) {
    this.updateFoods(mealFood).then(() => this.updateMealNutrients());
  }

  private updateFoods(mealFood:MealFood) {
    if (this.foods.indexOf(mealFood.foodId) == -1) {
      return this._foodService.getFood(mealFood.foodId).then(food => {
        this.foods[mealFood.foodId] = food;
      });
    } else {
      return Promise.resolve();
    }
  }

  private initMealFoods() {
    for (let mealFood of this.meal.foods) {
      this.mealFoods.push({
        'foodId': mealFood.foodId,
        'name': this.foods[mealFood.foodId].name,
        'amount': mealFood.amount
      });
    }
  }

  private initMealNutrients() {
    for (let nutrientId of Object.keys(this.nutrients)) {
      let nutrient = this.nutrients[nutrientId];
      this.mealNutrients.push({
        'nutrientId': nutrientId,
        'name': nutrient.name,
        'percent': this.getPercent(nutrientId)
      });
    }
  }

  private getPercent(nutrientId) {
    let amount = 0;
    for (let mealFood of this.mealFoods) {
      let food = this.foods[mealFood.foodId];
      amount += food.nutrients.find(foodNutrient => foodNutrient.nutrientId == nutrientId).amount * mealFood.amount / 100;
    }
    let recommendation = this.recommendations.find(recommendation => recommendation.nutrientId == nutrientId);
    return amount / recommendation.min * 100;
  }

  private updateMealNutrients() {
    for (let mealNutrient of this.mealNutrients) {
      mealNutrient.percent = this.getPercent(mealNutrient.nutrientId);
    }
  }
}