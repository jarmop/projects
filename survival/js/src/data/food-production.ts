import { humanCalorieNeedPerYear } from "../config.ts";

type Field = {
    name: string;
    product: string;
    production: number; // kg
    size: number; // km²
};

const fields: Field[] = [{
    name: "wheatfield",
    product: "wheat",
    production: 100000, // kg
    size: 1, // km²
}];

export const fieldsByKey: Record<string, Field> = {};
fields.forEach((field) => {
    fieldsByKey[field.name] = field;
});

type Food = {
    name: string;
    calories: number;
    unitSize: number; // in calories
};

export const foods: Food[] = [{
    name: "wheat",
    calories: 3000, // per kg
    unitSize: humanCalorieNeedPerYear,
}];

export function getFood(name: string) {
    return foods.find((f) => f.name === name);
}

export function kgToUnit(food: Food, kg: number) {
    const foodUnitSizeInKg = food.unitSize / food.calories;
    return kg / foodUnitSizeInKg;
}

export function kcalToUnit(food: Food, kcal: number) {
    return kcal / food.unitSize;
}
