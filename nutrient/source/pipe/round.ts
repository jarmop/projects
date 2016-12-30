import {Pipe, PipeTransform} from 'angular2/core';

@Pipe({name: 'round'})
export class roundPipe implements PipeTransform {
    transform(number) {
        return Math.round(number);
    }
}