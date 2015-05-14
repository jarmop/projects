
class TaxController
  pie

  constructor: (@$log, @TaxService) ->
    @$log.debug "constructing TaxController"
    @tax
    @getTax()

  getTax: () ->
    @$log.debug "getTax()"

    @TaxService.getTax()
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
          { label: "Netto", value: 22000},
        ]
      }
    });


controllersModule.controller('TaxController', TaxController)

