importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

   /*Update with yours config*/
  const firebaseConfig = {
    apiKey: "AIzaSyCnVAiK-L8VM_vA5qI_5xbOim525BYAs3Q",
    appId: "1:543501648377:web:3faf49752718b4e06bfd28",
    messagingSenderId: "543501648377",
    projectId: "ezdelivery-a538c",
   
   authDomain: "localhost",
  

   messagingSenderId: "263307381024",
   appId: "1:263307381024:web:dsds",
 
 };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });