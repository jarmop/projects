import {Component, OnInit} from 'angular2/core';
import {RouteParams} from 'angular2/router';
import {RecommendationService} from '../service/recommendation.service';
import {MealService} from '../service/meal.service';
import {FoodService} from '../service/food.service';
import {NutrientService} from "../service/nutrient.service";
import {amountPipe} from "../pipe/amount.pipe";

declare var Chart: any;

@Component({
    selector: 'meal',
    templateUrl: 'component/meal.component.html',
    pipes: [amountPipe]
})

export class MealComponent implements OnInit {
    meal: any;
    nutritionShareGroups = [];

    constructor(
        private _recommendationService: RecommendationService,
        private _mealService: MealService,
        private _foodService: FoodService,
        private _nutrientService: NutrientService,
        private _routeParams: RouteParams) {
    }

    ngOnInit() {
        this._recommendationService.getRecommendations().then(recommendations => {
            this._mealService.getMeal(1).then(meal => {
                let foodIds = [];
                for (let food of meal.foods) {
                    foodIds.push(food.id)
                }
                this._foodService.getFoodsByIds(foodIds).then(foods => {
                    this.initMeal(meal, foods);
                    this.initNutritionShares(recommendations, foods, meal.foods);
                });
            });
        });
    }

    goBack() {
        window.history.back();
    }

    private initMeal(meal, foods) {
        this.meal = {
            'foods': []
        };
        for (let food of foods) {
            this.meal.foods.push({
                'name': food.name,
                'amount': meal.foods.find(mealFood => mealFood.id == food.id).amount
            });
        }
    }

    private initNutritionShares(recommendations, foods, mealFoods) {
        let vitaminRecommendations = this._recommendationService.getRecommendationVitamins(recommendations);
        this.nutritionShareGroups.push(this.getNutritionShareGroup(vitaminRecommendations, foods, mealFoods, 'Vitamiinit'));
        let dietaryElementRecommendations = this._recommendationService.getRecommendationDietaryElements(recommendations);
        this.nutritionShareGroups.push(this.getNutritionShareGroup(dietaryElementRecommendations, foods, mealFoods, 'Kivennäis- ja hivenaineet'));
    }

    private getNutritionShareGroup(recommendations, foods, mealFoods, name) {
        let nutritionShareGroup = {
            'name': name,
            'nutrients': []
        };
        for (let recommendation of recommendations) {
            let nutrientValue = 0;
            for (let food of foods) {
                let multiplier = mealFoods.find(mealFood => mealFood.id == food.id).amount / 100;
                let nutrient = food.nutrients.find(nutrient => nutrient.nutrientId === recommendation.nutrientId);
                nutrientValue += nutrient.amount * multiplier;
            }
            nutritionShareGroup.nutrients.push(this.getNutritionShare(nutrientValue, recommendation));
        }
        return nutritionShareGroup;
    }

    private getNutritionShare(nutrientValue, recommendation) {        
        let nutritionShare = {
            'name': recommendation.name,
            'male': recommendation.male,
            'max': recommendation.max,
            'amount': 0,
            'unit': recommendation.unit,
            'percent': {
                'ok': 0,
                'over': 0,
                'tooMuch': 0,
            },
        };

        if (nutrientValue) {
            nutritionShare.amount = nutrientValue;
            nutritionShare.unit = recommendation.unit;
            this.calculatePercent(nutritionShare, nutrientValue, recommendation);
        }

        return nutritionShare;
    }

    private calculatePercent(nutritionShare, nutrientValue, recommendation) {
        nutritionShare.percent.ok = nutrientValue / recommendation.male * 100;
        if (nutrientValue > recommendation.male) {
            nutritionShare.percent.ok = recommendation.male / nutrientValue * 100;
            let over = nutrientValue - recommendation.male;
            if (nutrientValue > recommendation.max) {
                let tooMuch = recommendation.max ? nutrientValue - recommendation.max : 0;
                over -= nutritionShare.percent.tooMuch;
                nutritionShare.percent.tooMuch = tooMuch / nutrientValue * 100;
            }
            nutritionShare.percent.over = over / nutrientValue * 100;
        }
    }
}