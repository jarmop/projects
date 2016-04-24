import {Adapter} from "./adapter";

export class Firebase implements Adapter {
    getFoods() {
        return 'firebase';
    }
}