import {Injectable, Inject} from 'angular2/core';
import {FOODS} from '../mock/mock-foods';
import {NutrientService} from "../service/nutrient.service";
import {Adapter} from "../adapter/adapter";

@Injectable()
export class FoodService {
    constructor(
        @Inject('Adapter') private _adapter: Adapter
    ) {}

    getFoods() {
        return this._adapter.getFoods();
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
    
    getFoodVitamins(food) {
        let nutrientService = new NutrientService();
        return food.nutrients.filter(nutrient => nutrientService.vitaminIds.indexOf(nutrient.nutrientId) != -1);
    }

    getFoodDietaryElements(food) {
        let nutrientService = new NutrientService();
        return food.nutrients.filter(nutrient => nutrientService.dietaryElementIds.indexOf(nutrient.nutrientId) != -1);
    }
}