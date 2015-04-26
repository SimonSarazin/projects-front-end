module = angular.module("commons.base.controllers",
    ['commons.base.services', 'commons.accounts.controllers','commons.graffiti.services'])



module.controller("AbstractListCtrl", ($scope, FilterService) ->
    """
    Abstract controller that initialize some list filtering parameters and
    watch for changes in filterParams from FilterService
    Controllers using it need to implement a refreshList() method calling adequate [Object]Service
    """
    $scope.limit = 12
    $scope.params = {}

    $scope.getParams = ()->
        $scope.params['limit'] = $scope.limit
        $scope.params['q'] = FilterService.filterParams.query
        $scope.params['facet'] = FilterService.filterParams.tags

    $scope.refreshListGeneric = ()->
        $scope.getParams()
        $scope.refreshList()

    $scope.init = (limit, featured) ->
        if limit
             $scope.limit = limit
        
        # Refresh FilterService params
        FilterService.filterParams.query = ''
        FilterService.filterParams.tags = []
        $scope.refreshListGeneric()
    
        for param of FilterService.filterParams
            $scope.$watch(
                ()->
                    return FilterService.filterParams[param]
                ,(newVal, oldVal) ->
                    if newVal != oldVal
                        $scope.refreshListGeneric()
            )
)


module.controller("ObjectGetter", ($scope, Project, Profile) ->

    $scope.getObject = (objectTypeName, objectId) ->
        if objectTypeName == 'project'
            Project.one(objectId).get().then((ProjectResult) ->
                $scope.project = ProjectResult
            )
        if objectTypeName == 'profile'
            Profile.one(objectId).get().then((ProfileResult) ->
                $scope.profile = ProfileResult
            )
)

module.controller("FilterCtrl", ($scope, $stateParams, Tag, FilterService) ->

    console.log(" Init Filter Ctrl , state param ? ", $stateParams)
    $scope.objectType = 'project'
    $scope.suggestedTags = Tag.getList().$object
    $scope.tags_filter = []
    $scope.query_filter = ''

    $scope.load = (objectType)->
        console.log("loading filter on ", objectType)
        $scope.objectType = objectType

    $scope.refreshFilter = ()->
        """
        Update FilterService data
        """
        console.log("refreshing filter (ctrler).. ", FilterService.filterParams)
        tags_list = []
        for tag in $scope.tags_filter
            tags_list.push(tag.text)
        FilterService.filterParams.tags = tags_list
        FilterService.filterParams.query = $scope.query_filter
        console.log("AFTER refreshing filter (ctrler).. ", FilterService.filterParams)

    $scope.addToTagsFilter = (aTag)->
        simpleTag =
            text : aTag.name
        if $scope.tags_filter.indexOf(simpleTag) == -1
            $scope.tags_filter.push(simpleTag)
        $scope.refreshFilter()
)