import {Pipe, PipeTransform} from 'angular2/core';

@Pipe({name: 'amount'})
export class amountPipe implements PipeTransform {
    transform(amount) {
        if (!amount || parseInt(amount) == amount) {
            return amount;
        }
        return amount.toFixed(2).replace(/0$/, '').replace('.', ',');
    }
}