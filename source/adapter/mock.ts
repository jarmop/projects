import {Adapter} from "./adapter";
import {FOODS} from "../mock/mock-foods";

export class Mock implements Adapter {
    getFoods() {
        return Promise.resolve(FOODS);
    }
}