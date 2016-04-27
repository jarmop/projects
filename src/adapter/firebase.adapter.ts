import {Food} from "../food-model";
import Firebase = require('firebase');

export class FirebaseAdapter {
    private firebase = new Firebase("https://nutrient.firebaseio.com/");

    saveFood(food:Food) {
        console.log('save to firebase');
        console.log(food);
        this.firebase.child('foods').push(food, function (error) {
            if (error) {
                console.log(error);
            } else {
                console.log('DONE');
                process.exit();
            }
        });
    }
}