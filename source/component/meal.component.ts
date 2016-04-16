import {Component, OnInit, ViewChild, NgZone} from 'angular2/core';
import {RouteParams} from 'angular2/router';
import {RecommendationService} from '../service/recommendation.service';
import {MealService} from '../service/meal.service';
import {FoodService} from '../service/food.service';
import {NutrientService} from "../service/nutrient.service";
import {amountPipe} from "../pipe/amount.pipe";
import {roundPipe} from "../pipe/round";

declare var Chart:any;

@Component({
    selector: 'meal',
    templateUrl: 'component/meal.component.html',
    pipes: [amountPipe, roundPipe]
})

export class MealComponent implements OnInit {
    @ViewChild('addName') addName;
    meal:any;
    nutritionShareGroups = [];
    foods;
    selectedFood;
    isAddOpen = false;
    addForm = {
        'name': null,
        'amount': null
    };

    constructor(private _recommendationService:RecommendationService,
                private _mealService:MealService,
                private _foodService:FoodService,
                private _nutrientService:NutrientService,
                private _routeParams:RouteParams,
                private _ngZone: NgZone
    ) {}

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
                'food': food,
                'amount': meal.foods.find(mealFood => mealFood.id == food.id).amount
            });
        }
        // this.selectedFood = this.meal.foods[3];
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
                'total': 0,
            },
            'recommendation': recommendation
        };

        if (nutrientValue) {
            nutritionShare.amount = nutrientValue;
            nutritionShare.unit = recommendation.unit;
            this.calculatePercent(nutritionShare, nutrientValue, recommendation);
        }

        return nutritionShare;
    }

    private calculatePercent(nutritionShare, nutrientValue, recommendation) {
        // nutritionShare.percent.ok = nutrientValue / recommendation.male * 100;
        // if (nutrientValue > recommendation.male) {
        //     nutritionShare.percent.ok = recommendation.male / nutrientValue * 100;
        //     let over = nutrientValue - recommendation.male;
        //     if (nutrientValue > recommendation.max) {
        //         let tooMuch = recommendation.max ? nutrientValue - recommendation.max : 0;
        //         over -= nutritionShare.percent.tooMuch;
        //         nutritionShare.percent.tooMuch = tooMuch / nutrientValue * 100;
        //     }
        //     nutritionShare.percent.over = over / nutrientValue * 100;
        // }
        nutritionShare.percent.total = nutrientValue / recommendation.male * 100;
        nutritionShare.percent.ok = Math.min(nutritionShare.percent.total, 100);
    }

    remove(food) {
        this.meal.foods.splice(this.meal.foods.indexOf(food), 1);
        this.updateNutritionShares();
    }

    private updateNutritionShares() {
        for (let nutritionShareGroup of this.nutritionShareGroups) {
            for (let nutritionShare of nutritionShareGroup.nutrients) {
                nutritionShare.amount = this.getUpdatedAmount(nutritionShare);
                nutritionShare.percent = this.getUpdatedPercent(nutritionShare);
            }
        }
    }

    private getUpdatedAmount(nutritionShare) {
        let amount = 0;
        for (let food of this.meal.foods) {
            let multiplier = food.amount / 100;
            let nutrient = food.food.nutrients.find(nutrient => nutrient.nutrientId === nutritionShare.recommendation.nutrientId);
            amount += nutrient.amount * multiplier
        }

        return amount;
    }

    private getUpdatedPercent(nutritionShare) {
        let percent = {
            'ok': 0,
            'over': 0,
            'tooMuch': 0,
            'total': 0,
        }
        // percent.ok = nutritionShare.amount / nutritionShare.male * 100;
        // if (nutritionShare.amount > nutritionShare.male) {
        //     percent.ok = nutritionShare.male / nutritionShare.amount * 100;
        //     let over = nutritionShare.amount - nutritionShare.male;
        //     if (nutritionShare.amount > nutritionShare.max) {
        //         let tooMuch = nutritionShare.max ? nutritionShare.amount - nutritionShare.max : 0;
        //         over -= percent.tooMuch;
        //         percent.tooMuch = tooMuch / nutritionShare.amount * 100;
        //     }
        //     percent.over = over / nutritionShare.amount * 100;
        // }
        percent.total = nutritionShare.amount / nutritionShare.male * 100;
        percent.ok = Math.min(percent.total, 100);
        // if (nutritionShare.amount > nutritionShare.male) {
        //     percent.ok = 100;
        // }

        return percent;
    }

    editMode(food = null) {
        if (food) {
            return this.selectedFood === food;
        }
        return this.selectedFood;
    }

    openEdit(food) {
        this.selectedFood = food;
    }

    save(food) {
        this.selectedFood = null;
    }

    openAdd(el, a) {
        this.isAddOpen = true;
        this._ngZone.runOutsideAngular(() => {
            setTimeout(() => {
                this.addName.nativeElement.focus();
            }, 0);
        });
    }

    closeAdd() {
        this.isAddOpen = false;
    }
    
    saveAdd() {
        this.closeAdd();
    }
}