class CompareService

  @headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
  @defaultConfig = { headers: @headers }

  constructor: (@$log, @$http, @$q) ->
    @$log.debug "constructing CompareService"

  getTax: (form) ->
    @$log.debug "TaxService.getTax()"
    deferred = @$q.defer()

    # create deep copy from form
    params = $.extend(true, {}, form);
    params.salary = params.salary * 100

    @$http.get("/tax", {params: params})
    .success((data, status, headers) =>
      @$log.info("Successfully got tax - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get tax - status #{status}")
      deferred.reject(data)
    )


    deferred.promise



servicesModule.service('CompareService', CompareService)