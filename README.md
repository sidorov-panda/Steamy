# Steamy
https://funcodechallenge.com/task

# Author:
Alexey Sidorov
http://t.me/sidorov_panda
http://github.com/sidorov-panda

# Installation:
```
git clone https://github.com/sidorov-panda/Steamy.git
cd Steamy
pod install
```
# Debug:
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

# Disclaimer
Steam API периодически может глючить и выдавать пустые результаты или non-JSON ответы, иногда это возникает из-за преувличения количества запросов от одного API key.
Просьба учитывать это при тестировании. Спасибо!

# Описание архитектурного решения;
Проект написан на языке Swift и использует популярную архитектуру MV-VM.

UI биндится к ViewModel c использованием RxSwift, таблицы с использованием RxDatasource
Из ViewController во ViewModel данные биндятся в Input-ы,
а обратно, из ViewModel во ViewController через Output-ы

В других местах старался не использовать Rx, чтобы не усложнять понимание, но в некоторых случаях он настолько сокращает работу, что отказываться от его использования - преступление.

Код разбит на несколько основных частей:
SteamSDK - часть, отвечающая за запросы к Steam API и маппинг объектов в нативные модели.
Cases - Содержит кейсы приложения, экраны, билдеры, вью модели
Common - содержит общие классы, менеджеры, хелперы, которые используются в приложении


Файл steam_countries.json отвечает за географию, используется для опредления названия страны, штата, города.
Обновить файл в случае изменения данных в API

# Используемые методы из Steam API:
Я использую два эндпоинта для получения данных:
1. Steam API *"http://api.steampowered.com"
  * "IPlayerService/GetSteamLevel" - текущий уровень пользователя
  * "IPlayerService/GetBadges" - список бейджей пользователя
  * "ISteamUser/GetPlayerSummaries" - информация о пользователе
  * "IPlayerService/GetOwnedGames" - список купленных игр
  * "IPlayerService/GetRecentlyPlayedGames" - недавние сессии
  * "ISteamUserStats/GetUserStatsForGame" - статистика по игре
  * "ISteamUserStats/GetSchemaForGame" - список статистик и ачивок по игре
  * "ISteamUserStats/GetPlayerAchievements" - ачивки пользователя
  * "ISteamUser/GetFriendList" - друзья пользователя

2. Steam Store Api *"https://store.steampowered.com"*
  * "api/appdetails" - получение информации об игре

# Предложения по дальнейшему улучшению кода проекта.
1. В первую очередь перерабать график, придумал плюс-минус универсальное решение
2. Переработать навигацию, в случае расширения будет неудобно управлять навигацией и модулями
3. Дополнить RealmDataProvider недостающими методами, чтобы можно было использовать приложение автономно, даже без кеша
4. Переделать систему ошибок и их трансформацию между слоев

# Обоснование использования зависимостей проекта;
* pod 'Alamofire' - для удобной работы с сетью
* pod 'AlamofireImage' - для удобной загрузки изображений
* pod 'RxSwift' - для байндинга в архитектуре MVVM
* pod 'RxDataSources' - байндинг моделей таблицы в TableView
* pod 'ObjectMapper' - маппинг JSON в модели
* pod 'RealmSwift' - Realm DB
* pod 'SteamLogin' - WebView логин в Steam
* pod 'SnapKit' - Управление констрейнтами
* pod 'Charts' - Построение графиков, к сожалению нет опыта
* pod 'SVProgressHUD' - Отображение лоудеров
* pod 'XLPagerTabStrip' - Замена Таббару, необходио для дизайна
* pod 'ImageSlideshow', '~> 1.8.1' - Слайдшоу
* pod "ImageSlideshow/Alamofire" - Слайдшоу
