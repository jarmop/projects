import {Injectable, Inject} from 'angular2/core';
import {MEALS} from '../mock/mock-meals';
import {Adapter} from "../adapter/adapter";

@Injectable()
export class MealService {
  constructor(
    @Inject('Adapter') private _adapter:Adapter
  ) {}

  getMeals() {
    return Promise.resolve(MEALS);
  }

  getMeal(id:number) {
    return this._adapter.getMeal(id);
  }
}