import {Injectable} from 'angular2/core';
import {FOODS} from './mock-foods';

@Injectable()
export class FoodService {
    getFoods() {
        return Promise.resolve(FOODS);
    }

    getFood(id: number) {
        return Promise.resolve(FOODS).then(
            foods => foods.filter(food => food.id === id)[0]
        );
    }
}