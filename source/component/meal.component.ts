import {Component, OnInit, NgZone} from 'angular2/core';
import {RecommendationService} from '../service/recommendation.service';
import {MealService} from 'service/meal.service';
import {FoodService} from 'service/food.service';
import {NutrientService} from "service/nutrient.service";
import {amountPipe} from "pipe/amount.pipe";
import {roundPipe} from "pipe/round";
import {NgClass} from 'angular2/common';
import {MealFoodsComponent} from 'component/meal-foods.component';

@Component({
    selector: 'meal',
    templateUrl: 'component/meal.component.html',
    pipes: [amountPipe, roundPipe],
    directives: [NgClass, MealFoodsComponent]
})

export class MealComponent implements OnInit {
    mealFoods = [];
    mealNutrients = [];

    private meal;
    private foods;
    private nutrients;
    private recommendations;

    constructor(private _recommendationService:RecommendationService,
                private _mealService:MealService,
                private _foodService:FoodService,
                private _nutrientService:NutrientService,
                private _ngZone: NgZone
    ) {}

    ngOnInit() {
        this._mealService.getMeal(1).then(meal => {
            this.meal = meal;
            let foodIds = [];
            for (let food of meal.foods) {
                foodIds.push(food.foodId)
            }
            this._foodService.getFoodsByIds(foodIds).then(foods => {
                this.foods = foods;
                this._nutrientService.getNutrients().then(nutrients => {
                    this.nutrients = nutrients;
                    this._recommendationService.getRecommendations(1).then(recommendations => {
                        this.recommendations = recommendations;
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

    getPercentMin(percent) {
        return Math.min(percent, 100);
    }

    onFoodRemoved(mealFood) {
        let foodToDelete = this.foods.find(food => food.id == mealFood.foodId);
        this.foods.splice(this.foods.indexOf(foodToDelete), 1);
        this.updateMealNutrients();
    }
    
    private initMealFoods() {
        for (let mealFood of this.meal.foods) {
            this.mealFoods.push({
                'foodId': mealFood.foodId,
                'name': this.foods.find(food => food.id == mealFood.foodId).name,
                'amount': mealFood.amount
            });
        }
    }

    private initMealNutrients() {
        for (let nutrient of this.nutrients) {
            this.mealNutrients.push({
                'nutrientId': nutrient.id,
                'name': nutrient.name,
                'percent': this.getPercent(nutrient.id)
            });
        }
    }    

    private getPercent(nutrientId) {
        let amount = 0;
        for (let mealFood of this.mealFoods) {
            let food = this.foods.find(food => food.id == mealFood.foodId);
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