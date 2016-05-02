import {Injectable, Inject} from 'angular2/core';
import {NUTRIENTS} from "../mock/mock-nutrients";
import {Adapter} from "../adapter/adapter";

@Injectable()
export class NutrientService {
    vitaminIds = [1,2,3,4,5,6,7,8,9,10];
    dietaryElementIds = [11,12,13,14,15,16,17,18,19];

    constructor(
      @Inject('Adapter') private _adapter:Adapter
    ) {}

    getNutrients() {
        return this._adapter.getNutrients();
    }
}