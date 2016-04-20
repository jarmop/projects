import {Component, OnInit, Input, NgZone} from 'angular2/core';
import {RecommendationService} from '../service/recommendation.service';
import {MealService} from 'service/meal.service';
import {FoodService} from 'service/food.service';
import {NutrientService} from "service/nutrient.service";
import {amountPipe} from "pipe/amount.pipe";
import {roundPipe} from "pipe/round";
import {NgClass} from 'angular2/common';
import {MealFoodsComponent} from 'component/meal-foods.component';

declare var $: any;
declare var Bloodhound:any;

@Component({
    selector: 'meal-foods',
    templateUrl: 'component/meal-foods.component.html'
})
export class MealFoodsComponent implements OnInit {
    @Input() mealFoods: Array;

    // mealFoods = [];

    // private meal;
    // private foods;

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
        this.bloodhound = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.whitespace,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            local: this.states
        });
        this.initTypeahead();
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

    remove(mealFood) {
        // TODO emit event to parent
        
        // this.mealFoods.splice(this.mealFoods.indexOf(mealFood), 1);        
        // let foodToDelete = this.foods.find(food => food.id == mealFood.foodId);
        // this.foods.splice(this.foods.indexOf(foodToDelete), 1);        
        // this.updateMealNutrients();
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