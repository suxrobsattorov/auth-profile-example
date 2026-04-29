# auth_profile_example

Flutter auth UI example with phone OTP flow and prepared Google Sign-In flow.

## Google auth tayyorlangan qismlar

- `google_sign_in: ^7.2.0` qo'shildi.
- Login sahifasidagi `Google orqali kirish` tugmasi endi haqiqiy Google sign-in oqimini ochadi.
- Google'dan qaytgan `idToken`, foydalanuvchi emaili va `serverAuthCode` uchun tayyor state qo'shildi.
- iOS uchun `Info.plist` ichiga `GIDClientID` va required URL scheme kiritildi.
- Backend hali yo'q bo'lgani uchun Google credential hozircha API'ga yuborilmaydi; muvaffaqiyatli sign-in'dan keyin pastdan sheet ochilib, credential tayyor ekanini ko'rsatadi.

## Hozir ishlatilayotgan client ID lar

- iOS client ID: `913143229825-6t2ku4uup4ur3iv7u5lfsamdjtva27qe.apps.googleusercontent.com`
- Android client ID: `913143229825-4v21fk5cgponiurn4g99cn3t81ockli8.apps.googleusercontent.com`

## Muhim eslatmalar

- `google_sign_in` Android integratsiyasida, agar `google-services.json` ishlatilmasa, odatda web OAuth client (`serverClientId`) kerak bo'ladi. Android client ID'ning o'zi ko'p holatda yetarli bo'lmaydi.
- Demak Android production login uchun keyin yana bitta web OAuth client yaratib, `--dart-define=GOOGLE_SERVER_CLIENT_ID=...` bilan berish kerak bo'lishi mumkin.
- Google Console'dagi Android package name va iOS bundle ID loyihadagi qiymatlar bilan aynan mos bo'lishi kerak. Hozir loyihada:
  - Android `applicationId`: `com.example.auth_profile_example`
  - iOS bundle ID: `com.example.authProfileExample`
- Agar sizdagi OAuth clientlar boshqa package/bundle ID uchun yaratilgan bo'lsa, Google login ishlamaydi.

## Backend tayyor bo'lganda ulash

1. Backendda `/api/auth/google/` endpoint ochiladi.
2. Frontend `AuthGoogleAuthorized` state ichidagi `idToken` yoki `serverAuthCode` ni shu endpointga yuboradi.
3. Backend `access` va `refresh` qaytaradi.
4. Keyin mavjud `TokenStorage` va `AuthSuccess` oqimiga ulab yuboramiz.

## Tavsiya etilgan build

Google server client keyin tayyor bo'lsa, ishga tushirish quyidagicha bo'ladi:

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```
