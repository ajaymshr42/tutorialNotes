angular.module("test",['ngMaterial'])
.controller("testCtrl",['$scope',function($scope){

	$scope.locations=[
		{
			name:'Sector 48',
			id : 1234
		},
		{
			name:'Sohna Road',
			id : 4576
		}
	];
	$scope.test=function(basic){
		var pushLocations=[];
		var parsedLocations=JSON.parse(JSON.stringify(basic.loc));
		angular.forEach(parsedLocations,function(value,key){
			var innerObject=JSON.parse(value);
			var id=	innerObject.id;
			var name=innerObject.name;
			pushLocations[id]={
				id:id,
				name:name
			};
		});
		console.log(pushLocations);
	}
}]);