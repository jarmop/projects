class TaxController
  constructor: ($scope, @$log, @TaxService) ->
    @$log.debug "constructing TaxController"
    @form = {
      salary: 30000,
      municipality: 'Helsinki',
      age: 30
    }

    $scope.form = @form
    $scope.municipalityOptions = ['Helsinki', 'Nivala']

    @getTax($scope.form)

  getTax: (form) ->
    @$log.debug "getTax()"

    @TaxService.getTax(form)
    .then((response) =>
        @$log.debug response
        @updateView(response)
    ,(error) =>
        @$log.error "Unable to get Tax: #{error}"
    )


  updateView: (data) ->
    if @pie then @pie.destroy()

    @pie = new d3pie("pie", {
      header: {
        title: {
          text: "A very simple example pie"
        }
      },
      data: {
        content: [
          { label: "Valtion vero", value: data.governmentTax.tax },
          { label: "Kunnallisvero", value: data.municipalityTax.tax },
          { label: "Netto", value: @form.salary * 100 - data.governmentTax.tax - data.municipalityTax.tax},
        ]
      }
    });


controllersModule.controller('TaxController', TaxController)

