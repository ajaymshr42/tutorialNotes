// Initialize Firebase
  var config = {
    apiKey: "AIzaSyArqlA_cCJTxECIE_8wn5HacT3k1eHMYVQ",
    authDomain: "chatapp-3110c.firebaseapp.com",
    databaseURL: "https://chatapp-3110c.firebaseio.com",
    storageBucket: "chatapp-3110c.appspot.com",
  };
  firebase.initializeApp(config);

angular.module("simpleChat",['ui.router','ngStorage'])
.config(function($stateProvider, $urlRouterProvider) {
    $stateProvider
    .state('/', {
       	url:"/",
        views: {
            'main-view': {
                templateUrl: 'templates/main.html', 
                controller: 'mainCtrl'
            }
        }
    })
    .state('/chat', {
        url: '/chat',
        views: {
            'main-view': {
                templateUrl: 'templates/chat.html', 
                controller: 'chatCtrl'
            }
        }
    });
    $urlRouterProvider.otherwise("/");

})
.controller("mainCtrl",['$scope','$location','$localStorage',function($scope,$location,$localStorage){
    $scope.login=function(){
        var provider = new firebase.auth.GoogleAuthProvider();
        firebase.auth().signInWithPopup(provider).then(function(result) {
          var token = result.credential.accessToken;
          var admin = result.user;
          $localStorage['admin']=admin;
          console.log($localStorage['admin']);
        }).catch(function(error) {
          console.log(error);
        });
    };
    firebase.auth().onAuthStateChanged(function(admin) {
      if (admin) {
        $localStorage.admin=admin;
        console.log($localStorage['admin']);
      } else {
       console.log("Please sign in Admin first");
      }
    });

}])
.controller("chatCtrl",['$scope','$location','$localStorage',function($scope,$location,$localStorage){
     //getting user id
    aid=1234;
    $scope.uid=0;


    firebase.auth().onAuthStateChanged(function(admin) {
      if (admin) {
        console.log($localStorage['admin']);
      } else {
       console.log("Please sign in as Admin first");
      }
    });



    //establishing sessions and getting user continuos connection info
    var connectedRef = firebase.database().ref(".info/connected");
    var adminRef=firebase.database().ref('/presence/adminsPresent/'+aid);
    connectedRef.on("value", function(snap) {
      if (snap.val() === true) {
        console.log("Admin connected");
        adminRef.onDisconnect().remove(function(error){
            if(error){
                console.log(error.message);
            }else{
                console.log("Succesfully removed  Admin from presence");
                firebase.database().ref('/presence/usersPresent/'+$scope.uid+'/'+aid).remove(function(error){
                    if(error==null) console.log("Admin is now free from user list "+$scope.uid);
                });
            }
        });
        firebase.database().ref('/presence/adminsPresent/'+aid+'/'+aid).set(true,function(val){
            if(val){
                console.log(val.message);
            }else{
                console.log("Succesfully added Admin to presence");
            }
        });
      } else {
        console.log("Admin not connected");
      }
    });


    // getting which user is assigned to this admin

    firebase.database().ref('/presence/usersPresent/').on("value",function(snapshot){
        snapshot.forEach(function(childSnapshot){
            if(childSnapshot.numChildren() == 2 && $scope.uid==0){
              var obj=childSnapshot.val();
              console.log(obj);
              angular.forEach(obj,function(val,k){
                if(k!=aid) $scope.uid=k;
              });
            }
        });
        firebase.database().ref('/presence/adminsPresent/'+aid+'/'+$scope.uid).set(true,function(val){
            if(val){
                console.log(val.message);
            }else{
                console.log("Succesfully added User "+$scope.uid+" to chat with Admin");
            }
        });
    });
}]);