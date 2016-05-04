export interface Adapter {
  getFood(id:number);
  getFoods(ids:Array<number>);
  getAllFoods();
  getMeal(id:number);
  getNutrients();
  getRecommendations(id: string);
}