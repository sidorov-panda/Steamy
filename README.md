# Steamy
https://funcodechallenge.com/task

# Author:

Alexey Sidorov

http://t.me/sidorov_panda

ody344@gmail.com


Installation:
-----------
```
git clone https://github.com/sidorov-panda/Steamy.git
cd Steamy
pod install
```

Description:
-----------
**Описание экранов**

**0. Пользователь:**
* Текущий уровень пользователя
* Никнейм
* Страна, город
* Аватар
* Если пользователь с закрытым профилем - будет отображен эмоджи замочка после ника
 
**1. Профиль:**
 * Количество сыгранных часов, количество друзей и количество игр
 * Краткий список игр, возможность перехода к полному списку игр или в игру
  
 **2. Активити:**
 * Список недавних игровых сессий с возможностью перехода в игру
 
 **3. Список друзей:**
 * Список друзей онлайн
 * Список друзей оффлайн
 * Если пользователь с закрытым профилем - будет отображен эмоджи замочка после ника
 
 **4. Игра:**
 * Если игра - CS:GO, то показывается график для пары Убийства/Смерти, работает для любого пользователя, к которому перешел
 * Слайдшоу из скриншотов по игре
 * Стоимость игры
 * Описание игры
 * Список новостей с краткой информацией и возможностью перейти на полное описание
 * Возможность просмотра всех новостей 

Debug:
-----------
Для удобства тестирования я добавил возможность смены пользователя и добавления данных для статистики через диплинки:
Для изменения пользователя необходимо открыть ссылку с устройства:
```
steamy://setUser/<USER STEAM ID>
```
После необходимо перезапустить приложение

Для добавления рандомных данных статистики:
```
steamy://addStat/12
```
Вместо 12 подставьте сколько тестовых значений создать

Disclaimer
-----------
В качестве игры выбрана CS:GO, хотя верстка сделана универсальная
Steam API периодически может глючить и выдавать пустые результаты или non-JSON ответы, иногда это возникает из-за преувличения количества запросов от одного API key.
Просьба учитывать это при тестировании. Спасибо!

Описание архитектурного решения;
-----------
Проект написан на языке Swift и использует популярную архитектуру MV-VM.

UI биндится к ViewModel c использованием RxSwift, таблицы с использованием RxDatasource
Из ViewController во ViewModel данные биндятся в Input-ы,
а обратно, из ViewModel во ViewController через Output-ы

В других местах старался не использовать Rx, чтобы не усложнять понимание, но в некоторых случаях он настолько сокращает работу, что отказываться от его использования - преступление.

Файл steam_countries.json отвечает за географию, используется для опредления названия страны, штата, города
Обновить файл в случае изменения данных в API

Код разбит на несколько основных частей:
SteamSDK - часть, отвечающая за запросы к Steam API и маппинг объектов в нативные модели.
Cases - Содержит кейсы приложения, экраны, билдеры, вью модели
Common - содержит общие классы, менеджеры, хелперы, которые используются в приложении

Используемые методы из Steam API:
-----------
Я использую два эндпоинта для получения данных:
1. Steam API *"http://api.steampowered.com"
  * **"IPlayerService/GetSteamLevel"** - текущий уровень пользователя
  * **"IPlayerService/GetBadges"** - список бейджей пользователя
  * **"ISteamUser/GetPlayerSummaries"** - информация о пользователе
  * **"IPlayerService/GetOwnedGames"** - список купленных игр
  * **"IPlayerService/GetRecentlyPlayedGames"** - недавние сессии
  * **"ISteamUserStats/GetUserStatsForGame"** - статистика по игре
  * **"ISteamUserStats/GetSchemaForGame"** - список статистик и ачивок по игре
  * **"ISteamUserStats/GetPlayerAchievements"** - ачивки пользователя
  * **"ISteamUser/GetFriendList"** - друзья пользователя

2. Steam Store Api *"https://store.steampowered.com"*
  * **"api/appdetails"** - получение информации об игре

Предложения по дальнейшему улучшению кода проекта.
-----------
1. Перерабать график, придумал плюс-минус универсальное решение
2. Переработать навигацию, в случае расширения будет неудобно управлять навигацией и модулями
3. Дополнить RealmDataProvider недостающими методами, чтобы можно было использовать приложение автономно, даже без кеша
4. Переделать систему ошибок и их трансформацию между слоев
5. Переработал систему управления модулями
6. Рассмотреть все edge-кейсы

Обоснование использования зависимостей проекта;
-----------
* **'Alamofire'** - для удобной работы с сетью
* **'AlamofireImage'** - для удобной загрузки изображений
* **'RxSwift'** - для байндинга в архитектуре MVVM
* **'RxDataSources'** - байндинг моделей таблицы в TableView
* **'ObjectMapper'** - маппинг JSON в модели
* **'RealmSwift'** - Realm DB
* **'SteamLogin'** - WebView логин в Steam
* **'SnapKit'** - Управление констрейнтами
* **'Charts'** - Построение графиков, к сожалению нет опыта
* **'SVProgressHUD'** - Отображение лоудеров
* **'XLPagerTabStrip'** - Замена Таббару, необходимо для дизайна
* **'ImageSlideshow'**, '~> 1.8.1' - Слайдшоу
* **"ImageSlideshow/Alamofire"** - Слайдшоу
