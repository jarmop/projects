import {Injectable} from "angular2/core";
import {FoodService} from "./food.service";

declare var Bloodhound:any;

@Injectable()
export class AutocompleteService {
    private bloodhound;
    private mapFoodNameToId: Object = {};

    constructor(private _foodService: FoodService) {
        this._foodService.getAllFoods().then(foods => {
            this.bloodhound = new Bloodhound({
                datumTokenizer: Bloodhound.tokenizers.whitespace,
                queryTokenizer: Bloodhound.tokenizers.whitespace,
                local: this.getFoodNames(foods)
            });
        });
    }

    getSuggestionEngine() {
        return this.bloodhound;
    }

    getFoodNames(foods) {
        let foodNames = [];
        for (let foodId of Object.keys(foods)) {
            let food = foods[foodId];
            this.mapFoodNameToId[food.name] = foodId;
            foodNames.push(food.name);
        }
        return foodNames;
    }

    getFoodIdByName(foodName) {
        return this.mapFoodNameToId[foodName];
    }
}