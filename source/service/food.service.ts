import {Injectable} from 'angular2/core';
import {FOODS} from './mock-foods';

@Injectable()
export class FoodService {
    getFoods() {
        return Promise.resolve(FOODS);
    }

    getFoodsByIds(ids: number[]) {
        return Promise.resolve(FOODS).then(
            foods => foods.filter(food => ids.indexOf(food.id) != -1)
        );
    }

    getFood(id: number) {
        return Promise.resolve(FOODS).then(
            foods => foods.filter(food => food.id === id)[0]
        );
    }
}