import {Component, Input} from 'angular2/core';
import {roundPipe} from "pipe/round";

@Component({
    selector: 'meal-nutrients',
    templateUrl: 'component/meal-nutrients.component.html',
    pipes: [roundPipe],
})

export class MealNutrientsComponent {
    @Input() mealNutrients: Array;

    getPercentMin(percent) {
        return Math.min(percent, 100);
    }
}