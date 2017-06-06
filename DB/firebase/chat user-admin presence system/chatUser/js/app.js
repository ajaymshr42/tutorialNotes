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
          var user = result.user;
          $localStorage['user']=user;
          console.log($localStorage['user']);
        }).catch(function(error) {
          console.log(error);
        });
    };
    firebase.auth().onAuthStateChanged(function(user) {
      if (user) {
        $localStorage.user=user;
        console.log($localStorage['user']);
      } else {
       console.log("Please sign in as User first");
      }
    });

}])
.controller("chatCtrl",['$scope','$location','$localStorage',function($scope,$location,$localStorage){
     //getting user id
    uid=12;
    $scope.aid=0;


    firebase.auth().onAuthStateChanged(function(user) {
      if (user) {
        console.log($localStorage['user']);
      } else {
       console.log("Please sign in as User first");
      }
    });



    //establishing sessions and getting user continuos connection info
    var connectedRef = firebase.database().ref(".info/connected");
    var userRef=firebase.database().ref('/presence/usersPresent/'+uid);
    connectedRef.on("value", function(snap) {
      if (snap.val() === true) {
        console.log("User connected");
        userRef.onDisconnect().remove(function(error){
            if(error){
                console.log(error.message);
            }else{
                console.log("Succesfully removed  User from presence");
                firebase.database().ref('/presence/adminsPresent/'+$scope.aid+'/'+uid).remove(function(error){
                    if(error==null) console.log("user is now free from admin list "+$scope.aid);
                });
            }
        });
        firebase.database().ref('/presence/usersPresent/'+uid+'/'+uid).set(true,function(val){
            if(val){
                console.log(val.message);
            }else{
                console.log("Succesfully added User to presence");
            }
        });
      } else {
        console.log("User not connected");
      }
    });

    
    firebase.database().ref('/presence/adminsPresent/').on("value",function(snapshot){
        snapshot.forEach(function(childSnapshot){
          if(childSnapshot.numChildren() < 2 && $scope.aid==0){
            console.log(childSnapshot.val());
            $scope.aid=childSnapshot.key;
            console.log("Selected Admin to chat with "+uid+" is "+$scope.aid);
            firebase.database().ref('/presence/usersPresent/'+uid+'/'+$scope.aid).set(true,function(val){
                if(val){
                    console.log(val.message);
                }else{
                    console.log("Succesfully added Admin "+$scope.aid+" to chat with user");
                }
            });
          }
        });
    });

}]);