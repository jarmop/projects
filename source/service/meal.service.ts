import {Injectable} from 'angular2/core';
import {MEALS} from 'mock/mock-meals';

@Injectable()
export class MealService {
    getMeals() {
        return Promise.resolve(MEALS);
    }

    getMeal(id: number) {
        return Promise.resolve(MEALS).then(
            meals => meals.filter(meal => meal.id === id)[0]
        );
    }
}