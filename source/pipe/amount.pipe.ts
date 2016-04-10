import {Pipe, PipeTransform} from 'angular2/core';
/*
 * Raise the value exponentially
 * Takes an exponent argument that defaults to 1.
 * Usage:
 *   value | exponentialStrength:exponent
 * Example:
 *   {{ 2 |  exponentialStrength:10}}
 *   formats to: 1024
 */
@Pipe({name: 'amount'})
export class amountPipe implements PipeTransform {
    transform(amount) {
        if (!amount || parseInt(amount) == amount) {
            return amount;
        }
        return amount.toFixed(2).replace(/0$/, '').replace('.', ',');
    }
}
