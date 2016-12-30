import {Pipe, PipeTransform} from 'angular2/core';

@Pipe({name: 'amount'})
export class amountPipe implements PipeTransform {
    transform(amount) {
        if (!amount || parseInt(amount) == amount) {
            return amount;
        }
        return Number(amount.toPrecision(3)).toString().replace('.', ',');
    }
}