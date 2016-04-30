import {Adapter} from "./adapter";
import {Injectable} from "angular2/core";
import {Http} from "angular2/http";
import 'rxjs/add/operator/toPromise';

@Injectable()
export class Firebase implements Adapter {
  constructor(private http: Http) {}

  getFoods() {
    return this.http.get('https://nutrient.firebaseio.com/foods.json')
      .toPromise().then(response => response.json());
  }
}