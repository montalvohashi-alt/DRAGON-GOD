// Firebase Cloud Messaging Background Service Worker for St. Cecilia's College Global Alumni Portal
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDQb9fk1wfQyU-Qy6-sCABZ2izxOj1vU-c",
  projectId: "gen-lang-client-0379037546",
  messagingSenderId: "954422776214",
  appId: "1:954422776214:web:183e42f053667221174db7"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification ? payload.notification.title : "St. Cecilia's College Alumni Alert";
  const notificationOptions = {
    body: payload.notification ? payload.notification.body : "New update in your alumni portal.",
    icon: 'icons/Icon-192.png',
    badge: 'icons/Icon-192.png',
    data: payload.data || {}
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
