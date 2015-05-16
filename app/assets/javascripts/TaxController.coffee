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
    ###content = [
      { label: "Vero", value: data.totalTax },
      { label: "Netto", value: @form.salary * 100 - data.governmentTax.tax - data.municipalityTax.tax},
    ]###

    content = [
      { label: "Valtion vero", value: data.governmentTax.tax },
      { label: "Kunnallisvero", value: data.municipalityTax.tax }
    ]

    @createPie(content, null)


  createPie: (content, onClickCallback) ->
    @pie = new d3pie("pie", {
      data: {
        content: content
      },
      misc: {
        pieCenterOffset: {
          y: -50
        }
      }
      size: {
        canvasWidth: 540
      }
      ###callbacks: {
        onClickSegment: onClickCallback
      }###
    });

  ###openTaxPie: (segment) =>
    @$log.debug segment.label
    if (segment.data.label == "Vero")
      @pie.destroy()
      @createPie(@subContent, null)###




controllersModule.controller('TaxController', TaxController)

