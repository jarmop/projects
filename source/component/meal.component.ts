import {Component, OnInit, NgZone} from 'angular2/core';
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
    mealFoods = [];
    mealNutrients = [];

    private meal;
    private foods;
    private nutrients;
    private recommendations;

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
                    this._recommendationService.getRecommendationsGroup(1).then(recommendationsGroup => {
                        this.recommendations = recommendationsGroup.recommendations;
                        this.initMealFoods();
                        this.initMealNutrients();
                    });
                });


            });
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
                        source: this.bloodhound
                    }
                ).focus();
            }, 0);
        });
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

    getPercentMin(percent) {
        return Math.min(percent, 100);
    }

    remove(mealFood) {
        this.mealFoods.splice(this.mealFoods.indexOf(mealFood), 1);
        let foodToDelete = this.foods.find(food => food.id == mealFood.foodId);
        this.foods.splice(this.foods.indexOf(foodToDelete), 1);
        this.updateMealNutrients();
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
}