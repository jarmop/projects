import {Component, OnInit} from 'angular2/core';
import {RouteParams} from 'angular2/router';
import {FoodService} from '../service/food.service';
import {NutrientService} from "../service/nutrient.service";

@Component({
    selector: 'food',
    templateUrl: 'component/food.component.html',
})

export class FoodComponent implements OnInit {
    food;
    vitamins = [];
    dietaryElements = [];

    constructor(
        private _foodService: FoodService,
        private _nutrientService: NutrientService,
        private _routeParams: RouteParams) {
    }

    ngOnInit() {
        let id = +this._routeParams.get('id');
        this._foodService.getFood(id).then(food => {
            this.food = food;
            this._nutrientService.getNutrients().then(nutrients => {
                for (let i=0; i<food.nutrients.length; i++) {
                    let nutrient = nutrients.find(nutrient => nutrient.id === food.nutrients[i].nutrientId);
                    let nutrientData = {
                        'name': nutrient.name,
                        'unit': nutrient.unit,
                        'amount': food.nutrients[i].amount
                    };
                    if (this._nutrientService.vitaminIds.indexOf(nutrient.id) != -1) {
                        this.vitamins.push(nutrientData);
                    } else {
                        this.dietaryElements.push(nutrientData);
                    }

                }
                // this.vitamins = this._foodService.getFoodVitamins(food);
                // this.dietaryElements = this._foodService.getFoodDietaryElements(food);
            });

        });
    }

    goBack() {
        window.history.back();
    }
}