import {Component, OnInit, NgZone} from 'angular2/core';
import {RouteParams} from 'angular2/router';
import {RecommendationService} from '../service/recommendation.service';
import {MealService} from '../service/meal.service';
import {FoodService} from '../service/food.service';
import {NutrientService} from "../service/nutrient.service";
import {amountPipe} from "../pipe/amount.pipe";
import {roundPipe} from "../pipe/round";
import {NgClass} from 'angular2/common';

declare var $: any;
declare var Bloodhound:any;

@Component({
    selector: 'meal',
    templateUrl: 'component/meal.component.html',
    pipes: [amountPipe, roundPipe],
    directives: [NgClass]
})

export class MealComponent implements OnInit {
    meal;
    foods;
    nutrients;
    nutrientGroups = [];
    recommendations;
    percents = [];

    selectedFood;
    isAddOpen = false;
    addForm = {
        'name': null,
        'amount': null
    };
    states = ['banaani','porkkana','puuro','peruna','papu'];
    bloodhound;

    constructor(private _recommendationService:RecommendationService,
                private _mealService:MealService,
                private _foodService:FoodService,
                private _nutrientService:NutrientService,
                private _routeParams:RouteParams,
                private _ngZone: NgZone
    ) {}

    ngOnInit() {
        this._mealService.getMeal(1).then(meal => {
            this.meal = meal;
            let foodIds = [];
            for (let food of meal.foods) {
                foodIds.push(food.id)
            }
            this._foodService.getFoodsByIds(foodIds).then(foods => {
                this.foods = foods;
            });
        });

        this._nutrientService.getNutrients().then(nutrients => {
            this.nutrients = nutrients;
            this.nutrientGroups.push({
                'class': 'vitamins',
                'nutrients': nutrients.filter(nutrient => this._nutrientService.vitaminIds.indexOf(nutrient.id) != -1)
            });
            this.nutrientGroups.push({
                'class': 'dietary-elements',
                'nutrients': nutrients.filter(nutrient => this._nutrientService.dietaryElementIds.indexOf(nutrient.id) != -1)
            });
        });

        this._recommendationService.getRecommendationsGroup(1).then(recommendationsGroup => {
            this.recommendations = recommendationsGroup.recommendations;
        });
        
        this.bloodhound = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.whitespace,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            local: this.states
        });
        this.initTypeahead();
    }

    goBack() {
        window.history.back();
    }
    
    getFoodName(foodId) {
        return this.foods.find(food => food.id == foodId).name;
    }

    private getPercent(nutrientId) {
        if (this.percents[nutrientId] == undefined) {
            let amount = 0;
            for (let mealFood of this.meal.foods) {
                let food = this.foods.find(food => food.id == mealFood.id);
                amount += food.nutrients.find(foodNutrient => foodNutrient.nutrientId == nutrientId).amount * mealFood.amount / 100;
            }
            let recommendation = this.recommendations.find(recommendation => recommendation.nutrientId == nutrientId);
            this.percents[nutrientId] = amount / recommendation.min * 100;
        }
        return this.percents[nutrientId];
    }

    getPercentMin(nutrientId) {
        return Math.min(this.getPercent(nutrientId), 100);
    }

    getPercentTotal(nutrientId) {
        return this.getPercent(nutrientId);
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
        // for (let nutritionShareGroup of this.nutritionShareGroups) {
        //     for (let nutritionShare of nutritionShareGroup.nutrients) {
        //         nutritionShare.amount = this.getUpdatedAmount(nutritionShare);
        //         nutritionShare.percent = this.getUpdatedPercent(nutritionShare);
        //     }
        // }
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
        this.closeAdd();
    }

    save(food) {
        this.selectedFood = null;
    }

    openAdd(el, a) {
        this.isAddOpen = true;
        this.selectedFood = null;
        this.initTypeahead();
    }

    closeAdd() {
        this.isAddOpen = false;
    }
    
    saveAdd() {
        this.closeAdd();
    }

    private initTypeahead() {
        this._ngZone.runOutsideAngular(() => {
            setTimeout(() => {
                $('#add-name').typeahead(
                    {
                        hint: true,
                        highlight: true,
                        minLength: 1
                    },
                    {
                        name: 'states',
                        // source: this.substringMatcher(this.states)
                        source: this.bloodhound
                    }
                ).focus();
            }, 0);
        });
    }
}