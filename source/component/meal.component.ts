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
  private mealId = 0;

  constructor(
    private _recommendationService:RecommendationService,
    private _mealService:MealService,
    private _foodService:FoodService,
    private _nutrientService:NutrientService
  ) {}

  ngOnInit() {
    Promise.all([
      this.initMealFoods(),
      this.initNutrients(),
      this.initRecommendations()
    ]).then(() => {
      this.initMealNutrients();
    });
  }

  private initMealFoods() {
    return this._mealService.getMeal(this.mealId).then(meal => {
      let foodIds = [];
      for (let mealFoodId of Object.keys(meal.foods)) {
        foodIds.push(meal.foods[mealFoodId].foodId);
      }
      return this._foodService.getFoods(foodIds).then(foods => {
        this.foods = foods;
        for (let mealFoodId of Object.keys(meal.foods)) {
          let mealFood = meal.foods[mealFoodId];
          this.mealFoods.push({
            'id': mealFoodId,
            'foodId': mealFood.foodId,
            'name': this.foods[mealFood.foodId].name,
            'amount': mealFood.amount
          });
        }
      });
    });
  }

  private initNutrients() {
    this._nutrientService.getNutrients().then(nutrients => {
      this.nutrients = nutrients;
    })
  }

  private initRecommendations() {
    this._recommendationService.getRecommendations('-KGaiyy8KagLuplWuw70').then(recommendations => {
      this.recommendations = recommendations.recommendations;
    })
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

  goBack() {
    window.history.back();
  }

  removeMealFood(mealFood:MealFood) {
    this._mealService.removeFood(this.mealId, mealFood.id);
    this.updateMealNutrients();
  }

  saveMealFood(mealFood:MealFood) {
    this.updateFoods(mealFood).then(() => this.updateMealNutrients());
  }

  addMealFood(mealFood:MealFood) {
    this._mealService.addFood(this.mealId, mealFood.foodId, mealFood.amount);
    this.updateFoods(mealFood).then(() => this.updateMealNutrients());
  }

  private async updateFoods(mealFood:MealFood) {
    if (this.foods.indexOf(mealFood.foodId) == -1) {
      await this._foodService.getFood(mealFood.foodId).then(food => {
        this.foods[mealFood.foodId] = food;
      });
    }
  }

  private getPercent(nutrientId) {
    let amount = 0;
    for (let mealFood of this.mealFoods) {
      let food = this.foods[mealFood.foodId];
      let nutrient = food.nutrients.find(foodNutrient => foodNutrient.nutrientId == nutrientId);
      // TODO show missing data
      amount += nutrient ? nutrient.amount * mealFood.amount / 100 : 0;
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