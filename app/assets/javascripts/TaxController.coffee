
class TaxController

  constructor: (@$log, @TaxService) ->
  #constructor: () ->
    @$log.debug "constructing TaxController"
    @tax
    @getTax()


    pie = new d3pie("pie", {
      header: {
        title: {
          text: "A very simple example pie"
        }
      },
      data: {
        content: [
          { label: "JavaScript", value: 264131 },
          { label: "Ruby", value: 218812 },
          { label: "Java", value: 157618},
        ]
      }
    });

  getTax: () ->
    @$log.debug "getTax()"

    @TaxService.getTax()
    .then(
      (data) =>
        @$log.debug "Promise returned #{data.salary} Tax"
        @tax = data
    ,
      (error) =>
        @$log.error "Unable to get Tax: #{error}"
    )




controllersModule.controller('TaxController', TaxController)

