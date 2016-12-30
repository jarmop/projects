import {RECOMMENDATIONS} from '../lib/mock-recommendations';
import {FirebaseAdapter} from '../lib/adapter/firebase.adapter';

class RecommendationsProcessor {
  private firebase = new FirebaseAdapter;

  addRecommendations(recommendations) {
    return this.linkRecommendationsToNutrients(recommendations)
      .then(recommendations => this.firebase.addRecommendations(recommendations));
  }
  
  linkRecommendationsToNutrients(recommendations) {
    return this.firebase.getNutrients().then(result => {
      let nutrients  = result.val();
      let nutrientIds = Object.keys(nutrients);
      let linkedRecommendations = [];
      for(let i=0; i<nutrientIds.length; i++) {
        let linkedRecommendation = recommendations.recommendations[i];
        linkedRecommendation.nutrientId = nutrientIds[i];
        linkedRecommendations.push(linkedRecommendation);
      }
      recommendations.recommendations = linkedRecommendations;
      return recommendations;
    });
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