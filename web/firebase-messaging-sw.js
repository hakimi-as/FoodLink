importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBLDskxbQLyZkkylyJy_K59snweq4bAbWA',
  appId: '1:669111875092:web:6483be85eac9ab57185901',
  messagingSenderId: '669111875092',
  projectId: 'mysavefood-4bfd6',
  authDomain: 'mysavefood-4bfd6.firebaseapp.com',
  storageBucket: 'mysavefood-4bfd6.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification ?? {};
  self.registration.showNotification(title ?? 'FoodLink', {
    body: body ?? '',
    icon: '/icons/Icon-192.png',
  });
});
