class CompareService

  @headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
  @defaultConfig = { headers: @headers }

  constructor: (@$log, @$http, @$q) ->
    @$log.debug "constructing CompareService"

  getPercent: () ->
    @$log.debug "CompareService.getPercent"
    deferred = @$q.defer()

    @$http.get("/compare/percent").success((data, status, headers) =>
      @$log.info("Successfully got percent - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get percent - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

  getSum: () ->
    @$log.debug "CompareService.getSum"
    deferred = @$q.defer()

    @$http.get("/compare/sum").success((data, status, headers) =>
      @$log.info("Successfully got sum - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get sum - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

servicesModule.service('CompareService', CompareService)