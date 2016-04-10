import {Component, OnInit} from 'angular2/core';
import {RouteParams} from 'angular2/router';
import {FoodService} from '../service/food.service';
import {Food} from "../model/food";

@Component({
    selector: 'food',
    templateUrl: 'component/food.component.html',
})

export class FoodComponent implements OnInit {
    food;
    vitamins;
    dietaryElements;

    constructor(
        private _foodService: FoodService,
        private _routeParams: RouteParams) {
    }

    ngOnInit() {
        let id = +this._routeParams.get('id');
        this._foodService.getFood(id).then(food => {
            this.food = food;
            this.vitamins = this._foodService.getFoodVitamins(food);
            this.dietaryElements = this._foodService.getFoodDietaryElements(food);
        });
    }

    goBack() {
        window.history.back();
    }
}