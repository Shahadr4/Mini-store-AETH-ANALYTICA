# Mini Store

A small shopping app built for the Aeth Analytica Flutter machine task. A user logs in, browses products with pagination, searches, filters by category, manages a local cart, places a dummy order and views their account. All data comes from the free [DummyJSON](https://dummyjson.com) API.

## Flutter version

Flutter **3.41.4** (stable) · Dart **3.11** · Android and iOS (portrait only).

## How to run

```bash
flutter pub get
flutter run                 # debug on a connected device / emulator
flutter test                # unit + layout tests
flutter build apk --release # build/app/outputs/flutter-apk/app-release.apk
```

Test account: **username** `emilys` · **password** `emilyspass` (also shown on the login screen).

## State management: Provider

I used the `provider` package with `ChangeNotifier` only (no mixing with other solutions).

* Each provider is a plain `ChangeNotifier`: private fields, public getters, and `notifyListeners()` after a change. A tiny base class (`core/state/safe_change_notifier.dart`) skips the notification if the screen was already closed when a response arrives.
* Providers call use cases, so they are easy to unit test (see `test/`).
* Every list screen handles four states: **loading (shimmer), success, error (with Retry) and empty**.
* Providers are the only place with logic. Widgets only show data (`Consumer` / `Selector`) and forward user actions (`context.read`).

App-wide providers: `AuthProvider` (session), `CartProvider` (cart and badge), `ThemeProvider`. Screen providers (`ChangeNotifierProvider(create: ...)`) are created per screen from the service locator and disposed with the screen.

## Architecture

Clean Architecture, feature-first. Each feature has `data / domain / presentation`.

```
lib/
  core/
    constants/   api + storage keys, spacing
    di/          get_it service locator (injection.dart)
    error/       exceptions, failures, Result type, single error mapper (guard)
    network/     Dio factory, auth interceptor, TokenProvider
    router/      go_router config and redirects
    session/     SessionExpiredNotifier (network layer -> app)
    storage/     PrefsService (SharedPreferences wrapper)
    theme/       palette, text styles, ThemeData (light + dark)
    widgets/     reusable widgets (button, error/empty views, shimmer, ...)
  features/
    auth/        splash, login, session (login / logout / get saved user / check session)
    products/    home list, search, sort, details, reviews
    categories/  category list, products of a category
    cart/        local cart, dummy order, order success
    account/     profile, logout, dark mode
    main/        bottom navigation shell with cart badge
  main.dart
```

Rules that are followed:

* **Domain** is pure Dart (entities, abstract repositories, use cases). No Flutter, Dio or SharedPreferences imports.
* **Data** maps JSON to models (models extend the entities) and implements the repositories. Repositories hide where data comes from.
* **Presentation** talks to use cases only, never to Dio or SharedPreferences.
* **Errors**: data sources throw, repositories wrap calls in `guard()`, which is the only place exceptions become `Failure`s with friendly messages. The UI only sees `Result<T>`.
* **DI**: everything is registered in `core/di/injection.dart`. No objects are created inside widgets (`ChangeNotifierProvider(create: (_) => sl<...>())` only asks the locator).

### Authentication and session

* `AuthProvider` drives the router (it is the router's `refreshListenable`). `go_router`'s `redirect` sends the user to Splash, Login or Main whenever the session state changes, which gives auto-login, logout and the back-button rules for free.
* Splash, Login and Main are top-level routes opened with `go`, so each is the only page on the stack: **Back closes the app**, and after logout the stack is replaced so Main cannot be reached with Back.
* Tokens and user are saved in Shared Preferences (`access_token`, `refresh_token`, `user`).
* **401 handling** (required): `AuthInterceptor` adds the Bearer token to every request. On a 401 it refreshes the token (`POST /auth/refresh`) and retries the request once (bonus). If the refresh fails, the session is cleared and the user is sent to Login with the message "Your session has expired. Please log in again."

### Pagination

Shared by Home, search and category lists (`PagedProductsProvider`):

* `limit = 10`, next `skip` = number of products already loaded.
* Stops when `loaded >= total`. No request is made while another is running.
* Pull-to-refresh reloads from page 1 and keeps the old items visible until the new ones arrive.
* A failed next page keeps the items on screen and shows a small **Retry** at the bottom.
* Search is debounced by 500 ms; responses of outdated requests (old search text) are ignored.

## Features

* Splash with logo, login with validation and show/hide password, keyboard-safe form.
* Home grid with search, pagination, pull-to-refresh and **sorting** (price / rating, bonus).
* Product details: swipeable image carousel with dots, price, discount, rating, stock status, description, reviews, Add to Cart or quantity controls.
* Categories and products per category with pagination.
* Cart stored locally (survives restart), quantity controls, remove, totals, badge on the tab, dummy order flow with confirmation, 1.5 s loading and Order Success screen.
* Account: profile from the saved user, logout with confirmation, **dark mode** saved in Shared Preferences (bonus).
* Custom launcher icon and the app name "Mini Store" for Android and iOS.

## Packages

| Package | Why |
|---|---|
| `provider` | State management |
| `equatable` | Value equality for entities and failures |
| `get_it` | Dependency injection |
| `dio` | HTTP client, interceptor, error mapping |
| `shared_preferences` | Token, user, cart and theme storage |
| `go_router` | Navigation and auth redirects |
| `cached_network_image` | Images with placeholder and error icon |
| `shimmer` | Skeleton loaders |
| `smooth_page_indicator` | Dots under the image carousel |
| `flutter_launcher_icons` (dev) | Launcher icons |
| `mocktail` (dev) | Tests |

Poppins is bundled in `assets/fonts/` (no runtime download).

## Design

All colours and text styles are defined once in `lib/core/theme/` using the palette and Poppins styles from the task. Widgets read them from `Theme.of(context)` (`ColorScheme`, a `ThemeExtension` for the extra roles, and `TextTheme`), so no colours or font sizes are hard-coded in widgets. Spacing follows an 8 px grid with 16 px screen padding, buttons are 48 px high with radius 12.

### Premium look, same rules

The polish comes from layout, depth and motion, not from extra colours or font sizes: soft shadows (`SoftCard`), a primary-coloured `BrandHeader` with rounded corners on Login, Home and Account, product cards with a quick-add button, rating pill and old price, a details page whose info panel overlaps the image, a sticky price / add-to-cart bar, category icons, an animated splash and order-success screen, haptic feedback on add to cart and smooth page transitions. Everything still uses the task palette and the five Poppins styles.

## Tests

`flutter test` runs:

* cart use cases (add, increase, decrease to remove, place order),
* `ProductListProvider` (pagination rules, retry, debounce search, empty state),
* layout tests that render the product grid and cart tile on small, normal and tablet sizes with large text, to catch overflow.

## Assumptions

* The cart badge shows the **total quantity** of items. The cart is **kept after logout** because the task says it is only cleared when an order is placed.
* Cart prices use the product `price` field (not the discounted price) and the old price shown on details is derived from `discountPercentage`.
* DummyJSON does not validate the token on `/products`, only on routes like `/auth/me`, so the 401 flow was verified against `/auth/me`.
* The dark theme palette is my own choice (the task only defines the light one).
* The order number is generated locally (`#MS-xxxxx`). No order is stored.
* The app is locked to portrait.
* Android release builds are signed with the debug key (no keystore is committed). Use your own keystore for a store release.
* Application id: `com.example.mini_store` (change it for a store release).
