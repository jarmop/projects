
class TaxController

  constructor: (@$log, @TaxService) ->
  #constructor: () ->
    @$log.debug "constructing TaxController"
    @users = []
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

    ###@UserService.listUsers()
    .then(
      (data) =>
        @$log.debug "Promise returned #{data.length} Users"
        @users = data
    ,
      (error) =>
        @$log.error "Unable to get Users: #{error}"
    )###




controllersModule.controller('TaxController', TaxController)

