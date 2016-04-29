import {Food} from "../food-model";
import Firebase = require('firebase');

export class FirebaseAdapter {
  private firebase = new Firebase("https://nutrient.firebaseio.com/");

  saveFood(food:Food) {
    console.log('save to firebase');
    console.log(food);
    return this.firebase.child('foods').push(food);
  }

  truncateFoods() {
    return this.firebase.child('foods').remove();
  }

  addRecommendations(recommendations) {
    return this.firebase.child('recommendations').push(recommendations);
  }

  truncateRecommendations() {
    return this.firebase.child('recommendations').remove();
  }

  addNutrient(nutrient) {
    return this.firebase.child('nutrients').push(nutrient);
  }

  truncateNutrients() {
    return this.firebase.child('nutrients').remove();
  }
}