import {Component, Input} from 'angular2/core';
import {roundPipe} from "../pipe/round";
import {MealNutrient} from "../model/mealNutrient";

@Component({
    selector: 'meal-nutrients',
    templateUrl: 'component/meal-nutrients.component.html',
    pipes: [roundPipe],
})

export class MealNutrientsComponent {
    @Input() mealNutrients: Array<MealNutrient>;

    getPercentMin(percent) {
        return Math.min(percent, 100);
    }
}