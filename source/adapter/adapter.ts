import {OpaqueToken} from "angular2/core";
export interface Adapter {
    getFoods();
}

const Adapter = new OpaqueToken("Adapter");