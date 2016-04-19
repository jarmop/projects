import {Injectable} from 'angular2/core';
import {FOODS} from './mock-foods';
import {NutrientService} from "./nutrient.service";

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
    
    getFoodVitamins(food) {
        let nutrientService = new NutrientService();
        return food.nutrients.filter(nutrient => nutrientService.vitaminIds.indexOf(nutrient.nutrientId) != -1);
    }

    getFoodDietaryElements(food) {
        let nutrientService = new NutrientService();
        return food.nutrients.filter(nutrient => nutrientService.dietaryElementIds.indexOf(nutrient.nutrientId) != -1);
    }
}