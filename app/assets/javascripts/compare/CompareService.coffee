class CompareService

  @headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
  @defaultConfig = { headers: @headers }

  constructor: (@$log, @$http, @$q) ->
    @$log.debug "constructing CompareService"

  getData: () ->
    @$log.debug "CompareService.getData"
    deferred = @$q.defer()

    @$http.get("/compare/data").success((data, status, headers) =>
      @$log.info("Successfully got data - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get data - status #{status}")
      deferred.reject(data)
    )

    deferred.promise


servicesModule.service('CompareService', CompareService)