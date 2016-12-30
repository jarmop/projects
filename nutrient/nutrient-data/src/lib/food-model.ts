export interface Food {
  fineliId:number;
  name:string;
  nutrients:Array<FoodNutrient>;
}

export interface FoodNutrient {
  nutrientId:number;
  amount:number;
}