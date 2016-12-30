export interface Adapter {
  getFood(id:string);
  getFoods(ids:Array<number>);
  getAllFoods();
  getMeal(id:number);
  getNutrients();
  getRecommendations(id: string);
  addMealFood(mealId:number, foodId:string, foodAmount:number);
  updateMealFood(mealId:number, mealFoodId:string, foodAmount:number);
  removeMealFood(mealId:number, mealFoodId:string);
}