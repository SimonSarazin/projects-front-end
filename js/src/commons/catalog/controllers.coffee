module = angular.module("commons.catalog.controllers", ['commons.catalog.services', 'commons.base.controllers'])

module.controller("ProjectSheetListCtrl", ($scope, $controller, ProjectSheet, BareRestangular) ->
    angular.extend(this, $controller('AbstractListCtrl', {$scope: $scope}))
    
    $scope.seeMore = false

    $scope.refreshList = ()->
        ProjectSheet.one().customGETLIST('search', $scope.params).then((result)->
                console.log(" Refreshed ! ", result)
                $scope.projectsheets = result
                if result.metadata.next
                   $scope.seeMore = true
                   $scope.nextURL = result.metadata.next.slice(1) #to remove first begin slash
                else
                    $scope.seeMore = false
                   
            )

    $scope.loadMore = ()->
        BareRestangular.all($scope.nextURL).getList().then((result)->
                console.log("loading more !", result)
                for item in result
                    $scope.projectsheets.push(item)
                if result.metadata.next
                   $scope.seeMore = true
                   $scope.nextURL = result.metadata.next.slice(1) #to remove first begin slash
                else
                    $scope.seeMore = false
            )
        
)


module.controller("ProjectSheetCtrl", ($scope, $stateParams, $filter, ProjectSheet,
                                        Project, ProjectSheetQuestionAnswer, Bucket,
                                        @$http, FileUploader, $modal) ->

    $scope.init = ->
        Project.one().get({'slug' : $stateParams.slug}).then((projectResult)->
            $scope.project = projectResult.objects[0]
        )
        ProjectSheet.one().get({'project__slug' : $stateParams.slug}).then((projectsheetResult) ->
            $scope.projectsheet = projectsheetResult.objects[0]
            return projectsheetResult.objects[0]
        )

    $scope.updateProjectSheet = (resourceName, resourceId, fieldName, data) ->
        putData = {}
        putData[fieldName] = data
        switch resourceName
            when 'Project' then Project.one(resourceId).patch(putData)
            when 'ProjectSheetQuestionAnswer' then ProjectSheetQuestionAnswer.one(resourceId).patch(putData)
            when 'ProjectSheet' then ProjectSheet.one(resourceId).patch(putData)

    $scope.openGallery = (projectsheet) ->
        modalInstance = $modal.open(
            templateUrl: 'views/catalog/block/gallery.html'
            controller: 'GalleryInstanceCtrl'
            size: 'lg'
            resolve:
                params: ->
                    return {
                        projectsheet : projectsheet
                    }
        )
)

module.controller("ProjectSheetCreateCtrl", ($rootScope, $scope, ProjectSheet, Project, PostalAddress,
                                             ProjectSheetTemplate, ProjectSheetQuestionAnswer,
                                             @$http, FileUploader, $modal, ObjectProfileLink) ->

    $scope.uploader = new FileUploader(
        url: config.bucket_uri
        headers :
            Authorization : @$http.defaults.headers.common.Authorization
    )
    $scope.favorite = "-1" #To define which photo will be the cover
    $scope.videos = {}

    $scope.init = (templateSlug) ->
        console.log("Init Create controller ! ", templateSlug)
        $scope.projectsheet = {}
        $scope.QAItems = []

        ProjectSheetTemplate.one().get({'slug' : templateSlug}).then((templateResult) ->
            template = templateResult.objects[0]
            angular.forEach(template.questions, (question)->
                $scope.QAItems.push(
                    questionLabel : question.text
                    question : question.resource_uri
                    answer : ""
                    choices: question.choices
                )
            )
            console.log("Q_A_item", $scope.QAItems)
            $scope.projectsheet.template = template.resource_uri
        )

    $scope.saveProject = ()->
        console.log("saving project ..")
        if $scope.projectsheet.project.begin_date is undefined
            $scope.projectsheet.project.begin_date = new Date()

        $scope.projectsheet.project.slug = slug($scope.projectsheet.project.title)

        ProjectSheet.post($scope.projectsheet).then((projectsheetResult) ->
            angular.forEach($scope.QAItems, (q_a) ->
                q_a.projectsheet = projectsheetResult.resource_uri
                q_a.projectsheet_id = projectsheetResult.id
                ProjectSheetQuestionAnswer.post(q_a)
            )
            return projectsheetResult
        )

    $scope.savePhotos = (projectsheetID, bucketID) ->
        angular.forEach($scope.uploader.queue, (item) ->
            item.formData.push(
                bucket : bucketID
            )
            item.headers =
               Authorization : $scope.uploader.headers["Authorization"]
        )
        $scope.uploader.uploadAll()

        $scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
            if $scope.uploader.getIndexOfItem(fileItem) == $scope.favorite
                ProjectSheet.one(projectsheetID).patch({cover:response.resource_uri})

    $scope.saveVideos = (projectsheetID) ->
        ProjectSheet.one(projectsheetID).patch({videos:$scope.videos})

    $scope.openGallery = ->
        modalInstance = $modal.open(
            templateUrl: 'views/catalog/block/gallery.html'
            controller: 'GalleryInstanceCtrl'
            size: 'lg'
            resolve:
                params: ->
                    return {uploader : $scope.uploader, videos : $scope.videos, favorite : $scope.favorite}
        )
        modalInstance.result.then((result)->
            $scope.favorite = result.favorite
        , () ->
            return
        )
)




module.controller('GalleryInstanceCtrl', ($scope, $rootScope, $modalInstance, @$http, params, FileUploader, ProjectSheet, BucketFile) ->
    console.log('Init GalleryInstanceCtrl', params)
    # First check user is authenticated since upload triggers 403 and not gracefully intercepted 401 errors 
    if !$rootScope.authVars.isAuthenticated
        $rootScope.forceLogin()
    if params.projectsheet
        $scope.uploader = new FileUploader(
            url: config.bucket_uri
            headers :
                Authorization : @$http.defaults.headers.common.Authorization
        )
        $scope.bucket = params.projectsheet.bucket
        $scope.projectsheet = params.projectsheet
        $scope.videos = if params.projectsheet.videos then params.projectsheet.videos else {}

        $scope.uploader.onAfterAddingFile = (item) ->
            item.formData.push(
                bucket : $scope.bucket.id
            )
            item.headers =
               Authorization : $scope.uploader.headers["Authorization"]
            item.upload()

        $scope.uploader.onCompleteItem = (fileItem, response, status, headers) ->
            $scope.uploader.removeFromQueue(fileItem)
            $scope.bucket.files.push(response)
            if $scope.bucket.files.length == 1
                $scope.updateFavorite(response)

    else
        $scope.uploader = params.uploader
        $scope.videos = params.videos
        $scope.favorite = params.favorite
        $scope.cover = null

        $scope.uploader.onAfterAddingFile = (item) ->
            if $scope.uploader.queue.length == 1
                $scope.setFavorite(item)

    $scope.ok = ->
        result =
            uploader : $scope.uploader
            videos : $scope.videos
            favorite : $scope.favorite
        $modalInstance.close(result)

    $scope.cancel = ->
        $modalInstance.dismiss('cancel')

    $scope.addVideo = (newVideosURL) ->
        $scope.videos[newVideosURL] = null
        if $scope.projectsheet #EDIT MODE
            ProjectSheet.one($scope.projectsheet.id).patch({videos:$scope.videos})

    $scope.delVideo = (videosURL) ->
        delete $scope.videos[videosURL]
        if $scope.projectsheet #EDIT MODE
            ProjectSheet.one($scope.projectsheet.id).patch({videos:$scope.videos})

    $scope.setFavorite = (file) ->
        $scope.cover = file
        $scope.favorite = $scope.uploader.getIndexOfItem(file)


    $scope.removePicture = (file) ->#EDIT MODE
        fileIndex = $scope.bucket.files.indexOf(file)
        $scope.bucket.files.splice(fileIndex, 1)
        BucketFile.one(file.id).remove()

    $scope.updateFavorite = (file) ->#EDIT MODE
        $scope.projectsheet.cover = file
        ProjectSheet.one($scope.projectsheet.id).patch({cover:file.resource_uri})

)

module.controller("ProjectProgressCtrl", ($scope, Project, ProjectProgress) ->
    $scope.progressRange = []
    $scope.selectedClasses = {}

    $scope.updateProgressChoice = (progressChoice) ->
        $scope.selectedClasses = {}
        $scope.selectedClasses[progressChoice.id] = "selected"

    $scope.init = (projectID, projectProgressRangeSlug) ->

        ProjectProgress.getList({'range__slug' : projectProgressRangeSlug}).then((progressRangeResult) ->
            $scope.progressRange = progressRangeResult
            $scope.updateProgressChoice($scope.progressRange[0])
        )

)
