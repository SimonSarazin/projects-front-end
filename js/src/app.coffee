angular.module('commons.base', ['commons.base.controllers', 'commons.base.services'])
angular.module('commons.catalog', ['commons.catalog.controllers', 'commons.catalog.services'])
angular.module('commons.encommuns', ['commons.encommuns.controllers', 'commons.encommuns.services'])
angular.module('commons.accounts', ['commons.accounts.services', 'commons.accounts.controllers', 'commons.account.directives'])
angular.module('commons.ucomment', ['commons.ucomment.controllers', 'commons.ucomment.services'])
angular.module('imagination.catalog', ['imagination.catalog.controllers'])
angular.module('imagination', ['commons.catalog', 'commons.accounts', 'commons.encommuns','commons.ucomment', 'commons.base', 
                                'imagination.catalog',
                                'restangular', 'ui.bootstrap', 'ui.router', 'xeditable', 'textAngular', 'angularjs-gravatardirective', 'angularFileUpload',
                                'ngSanitize', 'ngTagsInput', 'angularMoment', 'angular-unisson-auth', 'leaflet-directive', "angucomplete-alt", "videosharing-embed"
                                'geocoder-service', 'ncy-angular-breadcrumb', 'truncate'])
# CORS
.config(['$httpProvider', ($httpProvider) ->
        $httpProvider.defaults.useXDomain = true
        delete $httpProvider.defaults.headers.common['X-Requested-With']
])

# Tastypie
.config((RestangularProvider) ->
        RestangularProvider.setBaseUrl(config.rest_uri)
        #RestangularProvider.setRequestSuffix('?format=json');
        # Tastypie patch
        RestangularProvider.setResponseExtractor((response, operation, what, url) ->
                newResponse = null;

                if operation is "getList"
                        newResponse = response.objects
                        newResponse.metadata = response.meta
                else
                        newResponse = response

                return newResponse
        )
)
# Google auth config
.config(['TokenProvider', '$locationProvider', (TokenProvider, $locationProvider) ->
    TokenProvider.extendConfig(
        clientId: config.oauthCliendId,
        redirectUri: config.oauthBaseUrl+'/oauth2callback.html',
        scopes: ["https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile"],
    )
])
# Unisson auth config
.config((loginServiceProvider) ->
    loginServiceProvider.setBaseUrl(config.loginBaseUrl)
)
# URI config
.config(['$locationProvider', '$stateProvider', '$urlRouterProvider', ($locationProvider, $stateProvider, $urlRouterProvider) ->

        $locationProvider.html5Mode(config.useHtml5Mode)
        $urlRouterProvider.otherwise("/")


        $stateProvider.state('home',
                url: '/',
                templateUrl: 'views/encommuns/description.html',
                ncyBreadcrumb:
                    label: 'Accueil'
        )
        .state('project',
                url: '/p/'
                abstract: true,
                templateUrl : 'views/catalog/project.html'
                ncyBreadcrumb:
                    parent: 'home'
        )
        .state('project.list',
                url: 'list',
                templateUrl: 'views/catalog/project.list.html',
                ncyBreadcrumb:
                    label: 'Projets'
        )
        .state('project.new',
                url: 'new',
                templateUrl: 'views/catalog/project.new.html',
                ncyBreadcrumb:
                    label: 'Nouveau projet'
                    parent : 'project.list'
        )
        .state('project.detail',
                url: ':slug',
                templateUrl: 'views/catalog/project.detail.html',
                controller : 'ImaginationProjectSheetCtrl'
                ncyBreadcrumb:
                    label: '{{project.title}}'
                    parent : 'project.list'
        )
        .state('profile',
                url : '/u/',
                abstract : true,
                templateUrl : 'views/profile/profile.html'
                ncyBreadcrumb:
                    parent: 'home'
        )
        .state('profile.list',
                url: 'list',
                templateUrl: 'views/profile/profile.list.html'
                ncyBreadcrumb:
                    label: 'Communauté'
        )
        .state('profile.detail',
                url: ':slug',
                templateUrl: 'views/profile/profile.detail.html'
                controller : 'ProfileCtrl'
                ncyBreadcrumb:
                    label: '{{profile.full_name}}'
                    parent : 'profile.list'
        )
        .state('profile.dashboard',
                url: ':slug/dashboard',
                templateUrl: 'views/profile/profile.dashboard.html'
                controller : 'ProfileCtrl'
                ncyBreadcrumb:
                    label: '{{profile.full_name}}'
                    parent : 'profile.detail'
        )
        .state('map',
                url: '/map/',
                templateUrl: 'views/map/map.html'
                ncyBreadcrumb:
                    label: 'Carte de la communauté'
                    parent : 'profile.list'
        )
        .state('about',
                url: '/about/',
                templateUrl: 'views/base/about.html'
                ncyBreadcrumb:
                    label: 'A propos'
                    parent : 'home'
        )
        .state('forum',
                url: '/discussions/',
                templateUrl: 'views/base/forum.html'
                ncyBreadcrumb:
                    label: 'Forum'
                    parent : 'home'
        )
        .state('tags',
                url: '/tags/',
                templateUrl: 'views/base/tag_listing.html'
                ncyBreadcrumb:
                    label: 'Tags'
                    parent : 'home'
        )
        .state('tag',
                url: '/tag/:slug',
                templateUrl: 'views/base/tagged_objects.html'
                controller : 'TaggedItemCtrl'
                ncyBreadcrumb:
                    label: '{{tag.slug}}'
                    parent : 'tags'
        )
        # .state('search',
        #         url: '/search/:query',
        #         templateUrl: 'views/base/search_result.html'
        #         controller : 'SearchCtrl'
        #         ncyBreadcrumb:
        #             label: 'Recherche'
        #             parent : 'home'
        # )
        .state('usages',
                url: '/usages'
                templateUrl: 'views/encommuns/usages.html'
        )
        .state('economique',
                url:'/economique'
                templateUrl:'views/encommuns/economique.html'
                controller: 'PrestationManagerCtrl'
        )
        .state('commons',
                url: '/c/'
                abstract: true,
                templateUrl : 'views/catalog/project.html'
                ncyBreadcrumb:
                    parent: 'home'
        )
        .state('commons.detail',
                url: ':slug',
                templateUrl: 'views/encommuns/project.detail.html',
                controller : 'ImaginationProjectSheetCtrl'
                ncyBreadcrumb:
                    label: '{{project.title}}'
                    parent : 'project.list'
        )
        .state('contribuer',
                url:'/contribuer'
                templateUrl:'views/encommuns/contribution.html'
        )

])
.run(($rootScope, editableOptions, editableThemes, amMoment, loginService, $state, $stateParams, CurrentProfileService) ->
    editableOptions.theme = 'bs3'
    editableThemes['bs3'].submitTpl = '<button type="submit" class="btn btn-primary">Enregistrer</button>'
    editableThemes['bs3'].cancelTpl = '<button type="button" class="btn btn-default" ng-click="$form.$cancel()">Annuler</button>'

    amMoment.changeLocale('fr');
    $rootScope.loginService = loginService
    $rootScope.config = config
    $rootScope.$state = $state
    $rootScope.$stateParams = $stateParams
    $rootScope.CurrentProfileService = CurrentProfileService

    $rootScope.Math = window.Math
)

angular.module('xeditable').directive('editableTextAngular', ['editableDirectiveFactory', (editableDirectiveFactory) ->
    return editableDirectiveFactory(
            directiveName : 'editableTextAngular'
            inputTpl : '<div text-angular></div>'
    )]
)
