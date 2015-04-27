module = angular.module("commons.encommuns.controllers", ['commons.encommuns.services','chartjs'])


module.controller("TestCtrl", ($scope) =>
    $scope.lineChartData = {
      labels: [
        'Gouvernance'
        'Technique'
        'Contribution'
        'Partage'
        'Juridique'
        'Mutualisation'
        'Financement'
        'Prestation'
        'Partenaires'
        'Evaluation'
        ]
      datasets: [
        {
          data: [300, 300, 350, 400, 200,400,300,200,180,290]
        }            
      ]
    }
    $scope.activeData = $scope.lineChartData;
)

module.controller('CollapseCtrl', ($scope) ->
    $scope.isCollapsed = true;
)

module.controller('TooltipCtrl', ($scope) ->
  $scope.dynamicTooltipText = 'dynamic';
)

class ListUsageManagerCtrl
        constructor: (@$scope, @Usages) ->
                @$scope.usages = @Usages.getList().$object 
module.controller("ListUsageManagerCtrl", ['$scope', 'Usages', ListUsageManagerCtrl])


module.controller("DetailUsageManagerCtrl", ($scope, OneUsage) ->
        $scope.detailledUsage = OneUsage.one($scope.usage.id).get().$object
) 

module.controller("DetailPertinenceManagerCtrl", ($scope, OnePertinence) ->
        $scope.detailledPertinence = OnePertinence.one($scope.pertinence.id).get().$object
) 

class PertinenceManagerCtrl
        constructor: (@$scope, @Pertinences) ->
                @$scope.pertinences = @Pertinences.getList().$object  


module.controller("PertinenceManagerCtrl", ['$scope', 'Pertinences', PertinenceManagerCtrl])


class HelpfulTipsManagerCtrl
        constructor: (@$scope, @HelpfulTips) ->
                @$scope.helpfultips = @HelpfulTips.getList().$object  

module.controller("HelpfulTipsManagerCtrl", ['$scope', 'HelpfulTips', HelpfulTipsManagerCtrl])

class PrestationManagerCtrl
        constructor: (@$scope, @Prestations) ->
                @$scope.prestations = @Prestations.getList().$object    

module.controller("PrestationManagerCtrl", ['$scope', 'Prestations', PrestationManagerCtrl])
