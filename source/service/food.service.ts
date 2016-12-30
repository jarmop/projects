import {Injectable, Inject} from 'angular2/core';
import {FOODS} from '../mock/mock-foods';
import {NutrientService} from "../service/nutrient.service";
import {Adapter} from "../adapter/adapter";

@Injectable()
export class FoodService {
  constructor(
    @Inject('Adapter') private _adapter:Adapter
  ) {}

  getFood(id:string) {
    return this._adapter.getFood(id);
  }

  getFoods(ids:number[]) {
    return this._adapter.getFoods(ids);
  }

  getAllFoods() {
    return this._adapter.getAllFoods();
  }
}