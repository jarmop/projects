import {Food} from "../food-model";
import Firebase = require('firebase');

export class FirebaseAdapter {
    private firebase = new Firebase("https://nutrient.firebaseio.com/");

    saveFood(food:Food) {
        console.log('save to firebase');
        console.log(food);
        return this.firebase.child('foods').push(food);
    }

    truncate() {
        return this.firebase.child('foods').remove();
    }
}