import {Component, OnInit} from "angular2/core";
import {FoodService} from "../service/food.service";

@Component({
  templateUrl: 'component/foods.component.html'
})
export class FoodsComponent implements OnInit {
  foodIds;
  foods;

  constructor(
    private _foodService:FoodService
  ) {}

  ngOnInit() {
    this._foodService.getFoods().then((foods) => {
      this.foodIds = Object.keys(foods);
      this.foods = foods;
    });
  }
}