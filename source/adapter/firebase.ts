import {Adapter} from "./adapter";
import {Injectable} from "angular2/core";
import {Http} from "angular2/http";
import 'rxjs/add/operator/toPromise';

@Injectable()
export class Firebase implements Adapter {
  constructor(private http: Http) {}

  getFood(id:number) {
    return this.http.get('https://nutrient.firebaseio.com/foods/' + id + '.json')
      .toPromise().then(response => response.json());
  }

  getAllFoods() {
    return this.http.get('https://nutrient.firebaseio.com/foods.json')
      .toPromise().then(response => response.json());
  }

  async getFoods(ids:Array<number>) {
    let foods = [];
    for (let id of ids) {
      foods[id] = await this.getFood(id);
    }
    return foods;
  }

  getMeal(id:number) {
    return this.http.get('https://nutrient.firebaseio.com/meals/' + id + '.json')
      .toPromise().then(response => response.json());
  }

  getNutrients() {
    return this.http.get('https://nutrient.firebaseio.com/nutrients.json')
      .toPromise().then(response => response.json());
  }

  getRecommendations(id:string) {
    return this.http.get('https://nutrient.firebaseio.com/recommendations/' + id + '.json')
      .toPromise().then(response => response.json());
  }
}