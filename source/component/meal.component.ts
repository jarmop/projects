import {Component, OnInit} from 'angular2/core';
import {RouteParams} from 'angular2/router';
// import {MealService} from '../service/meal.service';
// import {Meal} from "../model/meal";

@Component({
    selector: 'meal',
    templateUrl: 'component/meal.component.html',
})

export class MealComponent implements OnInit {
    // meal: Meal;

    constructor(
        // private _mealService: MealService,
        private _routeParams: RouteParams) {
    }

    ngOnInit() {
        // let id = +this._routeParams.get('id');
        // this._mealService.getMeal(id).then(meal => this.meal = meal);
    }

    goBack() {
        window.history.back();
    }
}