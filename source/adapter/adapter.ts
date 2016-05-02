export interface Adapter {
    getFoods();
    getFoodsByIds(ids:Array<number>);
    getMeal(id:number);
}