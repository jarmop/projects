import {Injectable} from 'angular2/core';
import {RECOMMENDATIONS} from './mock-recommendations';

@Injectable()
export class RecommendationService {
    getRecommendations() {
        return Promise.resolve(RECOMMENDATIONS);
    }
}