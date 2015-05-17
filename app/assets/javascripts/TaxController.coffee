class TaxController
  constructor: (@$scope, @$log, @TaxService, PieService) ->
    @$log.debug "constructing TaxController"
    @form = {
      salary: 30000,
      municipality: 'Helsinki',
      age: 30
    }

    @$scope.form = @form
    @$scope.municipalityOptions = ['Helsinki', 'Nivala']

    @pie = PieService

    @getTax(@$scope.form)

  getTax: (form) ->
    @$log.debug "getTax()"
    @TaxService.getTax(form)
    .then((response) =>
      @$log.debug response
      @pie.createBasicPie(response.totalTax, @form.salary * 100, @openTaxPie)
      @pie.createTaxPie(response)
      @updateReport(response)
    ,(error) =>
      @$log.error "Unable to get Tax: #{error}"
    )

  updateReport: (data) ->
    @$scope.salary = @formatCurrency(@form.salary)
    @$scope.commonDeduction = {}
    $.each(data.commonDeduction, (key, value) =>
      @$scope.commonDeduction[key] = @formatCurrencyCents(value)
    )

    governmentTaxHits = []
    $.each(data.governmentTax.hits, (key, value) =>
      governmentTaxHits.push({
        maxSalary: value.maxSalary / 100,
        taxPercent: @formatPercent(value.taxPercent)
        tax: @formatCurrencyCents(value.tax),
        taxedSalary: @formatCurrencyCents(value.taxedSalary),
        minSalary: value.minSalary / 100,
      })
    )

    @$scope.governmentTax = {
      deduction: @formatCurrencyCents(data.governmentTax.deduction),
      deductedSalary: @formatCurrencyCents(data.governmentTax.deductedSalary),
      sum: @formatCurrencyCents(data.governmentTax.sum),
      hits: governmentTaxHits
    }

    @$log.debug @$scope.governmentTax.hits

    @$scope.perDiemPayment = {
      percent: @formatPercent(data.perDiemPayment.percent),
      sum: @formatCurrencyCents(data.perDiemPayment.sum)
    }
    @$scope.pensionContribution = {
      tyel53Percent: @formatPercent(data.pensionContribution.tyel53Percent),
      tyelSub53Percent: @formatPercent(data.pensionContribution.tyelSub53Percent),
      percent: @formatPercent(data.pensionContribution.percent),
      sum: @formatCurrencyCents(data.perDiemPayment.sum)
    }
    @$scope.unemploymentInsurance = {
      percent: @formatPercent(data.unemploymentInsurance.percent),
      sum: @formatCurrencyCents(data.unemploymentInsurance.sum)
    }

  formatCurrency: (currency) ->
    return (currency).toFixed(2).toString().replace('.', ',')

  formatCurrencyCents: (currency) ->
    return @formatCurrency(currency / 100)

  formatPercent: (percent) ->
    return (percent * 100).toFixed(2).toString().replace(/0$|\.00$/, '').replace('.', ',')

controllersModule.controller('TaxController', TaxController)

