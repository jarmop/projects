import {Injectable} from 'angular2/core';
import {RECOMMENDATIONS} from './mock-recommendations';
import {NUTRIENTS} from "./mock-nutrients";

@Injectable()
export class NutrientService {
    vitaminIds = [1,2,3,4,5,6,7,8,9,10];
    dietaryElementIds = [11,12,13,14,15,16,17,18,19];

    getNutrients() {
        return Promise.resolve(NUTRIENTS);
    }
}