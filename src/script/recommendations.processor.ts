import {RECOMMENDATIONS} from '../lib/mock-recommendations';
import {FirebaseAdapter} from '../lib/adapter/firebase.adapter';

class RecommendationsProcessor {
  private firebase = new FirebaseAdapter;

  addRecommendations(recommendations) {
    return this.firebase.addRecommendations(recommendations);
  }

  truncate() {
    return this.firebase.truncateRecommendations();
  }
}

function finish(message) {
  return function() {
    console.log(message);
    process.exit();
  }
}

let recommendationsProcessor = new RecommendationsProcessor();
if (process.argv.indexOf('truncate') != -1) {
  recommendationsProcessor.truncate().then(finish('Truncated!'));
} else {
  recommendationsProcessor.addRecommendations(RECOMMENDATIONS[0]).then(finish('Added recommendation!'));
}