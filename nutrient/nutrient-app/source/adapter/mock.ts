import {Adapter} from "./adapter";
import {FOODS} from "../mock/mock-foods";

export class Mock {
    getFoods() {
        // return Promise.resolve(FOODS);
        return 'mock';
    }
}