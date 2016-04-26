export interface Food {
    id: number;
    name: string;
    nutrients: Array<FoodNutrient>;
}

export interface FoodNutrient {
    nutrientId:number;
    amount:number;
}