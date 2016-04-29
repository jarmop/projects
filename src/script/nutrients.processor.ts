import {NUTRIENTS} from '../lib/mock-nutrients';
import {FirebaseAdapter} from '../lib/adapter/firebase.adapter';

class NutrientsProcessor {
  private firebase = new FirebaseAdapter;

  addNutrient(nutrient) {
    return this.firebase.addNutrient(nutrient);
  }

  truncate() {
    return this.firebase.truncateNutrients();
  }
}

function finish(message) {
  return function() {
    console.log(message);
    process.exit();
  }
}

async function addNutrients(nutrients) {
  for (let nutrient of nutrients) {
    console.log('Adding nutrient: ' + nutrient.id);
    await nutrientsProcessor.addNutrient(nutrient);
    console.log('Added nutrient: ' + nutrient.id);
  }
}

let nutrientsProcessor = new NutrientsProcessor();
if (process.argv.indexOf('truncate') != -1) {
  nutrientsProcessor.truncate().then(finish('Truncated!'));
} else {
  addNutrients(NUTRIENTS).then(finish('Added all nutrients!'));
}