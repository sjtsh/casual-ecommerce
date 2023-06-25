'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "f5b3cc29bd853ef5d1a8b11e8fca4b64",
"assets/assets/app%2520store.png": "6e9ff349fe3d42adbb50cb7274b1fbb3",
"assets/assets/apple.png": "753b6d8e531276dda333084568ce47d4",
"assets/assets/Biscuits,%2520Packed%2520%2520Snacks%2520&%2520Sweets.png": "14f1297ab64044ba43262c249ed6ec99",
"assets/assets/bottle.png": "f3a1c06cc908cd3f771e8e04c4b4064d",
"assets/assets/call_icon.png": "326ed8dd682417522176d4c259ec070a",
"assets/assets/deliveringto.png": "a9bbf13473e61f76a01103438c3d3625",
"assets/assets/delivery_guy.png": "1eab969c178a512e37ac669a41a4136e",
"assets/assets/deliver_goods.png": "6b059de17f2ddd2c940d92f325f6bcb0",
"assets/assets/google%2520play.png": "85fe620002562d9bfb452001914926f5",
"assets/assets/Ketchup%2520,%2520Jam%2520%2520&%2520Pickles.png": "8a72688f567c7a615ba5285ef5c1027c",
"assets/assets/logo_gradient.png": "6cf63655336c53494a99254a590d9f0a",
"assets/assets/logo_white.png": "74d8051316c246d26decdc2845faaf30",
"assets/assets/logo_with_name_gradient.png": "df27798990400ea5c47ea2940f76e846",
"assets/assets/logo_with_name_white.png": "97d12c26e968f9d4729f1ac690476b66",
"assets/assets/love1.png": "7e0297620fb5d020d4d3a0eb3e309b83",
"assets/assets/love2.png": "ca41080ee4d0aff0dc87d14e3478a2bd",
"assets/assets/love3.png": "21cbc466ce0479c3e52006c77eff2813",
"assets/assets/mail.png": "846f3c05277c65eb20ce3d582b7cb308",
"assets/assets/Meat,%2520Eggs%2520&%2520Frozen%2520Snacks.png": "77de425a888303864ce75e49ce7585af",
"assets/assets/mockup.png": "533159cf8515aeba8e096bdb7f815560",
"assets/assets/nepal.png": "00fe420e168bd81f12751899b23ef732",
"assets/assets/toast.png": "fcb75637fd18938c46f50b216ef81615",
"assets/assets/Vegetables%2520&%2520%2520Fruits.png": "7fab897bbcb02259d0887722fd0ce31e",
"assets/assets/whatsapp.png": "2d3f268d4f50b0a121cfe8a060caff9a",
"assets/FontManifest.json": "a84bbd3395a3bdb46bc6e4a52973cac3",
"assets/fonts/config.json": "0c485512673d48fe39b940641f56209e",
"assets/fonts/GroceliIcon.ttf": "534d63e618e6742806994c815a21e1ea",
"assets/fonts/Inter-Medium.ttf": "e5f18cb987385760e628a9671f975412",
"assets/fonts/Inter-Regular.ttf": "851660f90f21dba5ec35b1765fdd426a",
"assets/fonts/Inter-SemiBold.ttf": "a2c4e8821556fa8b48d943a39f9da10c",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "20d2b70c4ecf1bf0e0687d33d8760d07",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"canvaskit/canvaskit.js": "97937cb4c2c2073c968525a3e08c86a3",
"canvaskit/canvaskit.wasm": "3de12d898ec208a5f31362cc00f09b9e",
"canvaskit/profiling/canvaskit.js": "c21852696bc1cc82e8894d851c01921a",
"canvaskit/profiling/canvaskit.wasm": "371bc4e204443b0d5e774d64a046eb99",
"favicon.png": "febd145488798e008fe9c553123c5b0b",
"flutter.js": "1cfe996e845b3a8a33f57607e8b09ee4",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "c428ad794b61a5752d8bfc2d25576076",
"/": "c428ad794b61a5752d8bfc2d25576076",
"main.dart.js": "66cd6ffcb6fdd1f2be017d74e8e0f257",
"manifest.json": "a622eddd614a7706253697825a63556c",
"splash/img/dark-1x.png": "b5d3789f19c257d73c997c30f5cc7aed",
"splash/img/dark-2x.png": "33763aec0804446ba057bda382bc4d5d",
"splash/img/dark-3x.png": "10c546a8b97538faac2dcb69a19a5ba6",
"splash/img/dark-4x.png": "a582573c12b4b9595360c9de054df2f8",
"splash/img/light-1x.png": "b5d3789f19c257d73c997c30f5cc7aed",
"splash/img/light-2x.png": "33763aec0804446ba057bda382bc4d5d",
"splash/img/light-3x.png": "10c546a8b97538faac2dcb69a19a5ba6",
"splash/img/light-4x.png": "a582573c12b4b9595360c9de054df2f8",
"splash/splash.js": "123c400b58bea74c1305ca3ac966748d",
"splash/style.css": "db1f3a732bcf53070ac483b40286da85",
"version.json": "782c78bbcf729ed6f3831f42aba008f3"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
