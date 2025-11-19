# Моя нынешняя архитектура проекта, дальнейшие действия будут происходить именно с ней, учитывай это при следующих промптах

## 🏗️ Архитектура проекта

### Основная структура
```
Components/
	├── AbstractPassives/    → Абстрактные пассивные способности
│   └── Default/         → Область видимости (scope)
│       └── Test/        → Конкретная пассивная способность
├── EntityComponent/     → Базовый компонент сущности
│   ├── DataComponent/   → Компонент данных
│   └── PassiveComponent/ → Компонент пассивных способностей
└── PlayerComponent/     → Компонент игрока (наследует EntityComponent)
└── CharacterComponent/ → Компонент персонажа

Initializators/
	└── PlayerInit/          → Инициализация игроков (события добавления/удаления)

Services/
	└── PlayerComponentService/ → Сервис управления компонентами игроков

Interfaces/
	├── PassiveInterfaces/   → Интерфейсы пассивных способностей
└── PlayerInterfaces/    → Интерфейсы игрока

Templates/
	└── SessionData/         → Шаблон данных сессии
```

## 🔄 Принцип работы компонентной системы

### Система метатаблиц и __index
Проект использует мощную систему делегирования через метатаблицы:
	- **EntityComponent** → базовый поиск по компонентам
- **PlayerComponent** → расширенный поиск (компоненты → entity → PlayerComponent)
- **Динамическое наследование** через `__index` функции

### Поток данных
1. **PlayerAdded** → PlayerInit → PlayerComponentService.CreateComponent()
2. **PlayerComponent.new()** → создает EntityComponent + настраивает метатаблицы
3. **Компоненты загружаются** автоматически из папок
4. **Делегирование методов** через __index функции

## 📋 Интерфейсы и типизация

### IPassiveInterfaces
```lua
IPassiveMethods = {
	New: (self) → (),
	SetupData: (level: number) → ()
}

IPassive = {
	OnStart: (self) → ()
}

IPassiveComponents = IPassiveMethods & IPassive
```

### IPlayerInterfaces  
```lua
IServerPlayerMethods = {
	SetupCharacter: (self) → (),
	AppendPassive: (self, scope: string, passiveName: string) → ()
}

IServerPlayerComponent = IServerPlayerMethods & {
	Instance: Player,
	SessionData: ISessionData
}
```

## 🗄️ Структура данных SessionData

### Шаблон данных сессии
```lua
SessionData = {
	Attributes = { Health, MaxHealth, WalkSpeed, JumpPower },
	CharacterData = {},
	StatusEffects = { Stun = boolean },
	Passives = {IPassiveComponents},
	Abilities = {},
	Threads = {},
	Tasks = {}
}
```

## 🔧 Ключевые модули и их функции

### EntityComponent (Базовый)
- **Загрузка компонентов**: автоматический require всех дочерних модулей
- **Делегирование**: поиск методов в загруженных компонентах
- **Сессия**: создание SessionData через LoadSession()

### PlayerComponent (Наследник EntityComponent)
- **Расширенное делегирование**: компоненты → entity → PlayerComponent
- **Инициализация**: настройка персонажа и добавление пассивных способностей
- **Привязка к игроку**: хранение ссылки на Instance (Player)

### PlayerComponentService (Менеджер)
- **Создание/удаление**: управление компонентами по UserId
- **Хранение**: кеширование компонентов игроков
- **Доступ**: получение компонента по игроку

### PassiveComponent (Управление пассивками)
- **Кеширование**: PassivesCache для избежания повторных require
- **Добавление**: AppendPassive() с указанием области и имени
- **Инициализация**: автоматический вызов OnStart()

### CharacterComponent (Управление персонажем)
- **Настройка**: привязка Humanoid и HumanoidRootPart
- **Обработка смерти**: сброс статусов и атрибутов при respawn
- **Отслеживание**: CharacterAdded события

## 🎯 Практическое использование

### Пример обращения к компонентам
```lua
-- Через делегирование __index автоматически находятся:
playerComponent:SetupCharacter()  -- из CharacterComponent
playerComponent:AppendPassive()   -- из PassiveComponent  
playerComponent:LoadSession()     -- из DataComponent
```

### Добавление новой пассивной способности
1. Создать модуль в `AbstractPassives/Default/`
2. Реализовать интерфейс IPassiveComponents
3. Вызвать `playerComponent:AppendPassive("Default", "NewPassive")`

## 🔄 Жизненный цикл игрока

1. **PlayerAdded** → создание PlayerComponent
2. **SetupCharacter** → настройка персонажа
3. **AppendPassive** → добавление стартовых пассивок
4. **Игровой процесс** → использование методов компонентов
5. **PlayerRemoving** → очистка компонента

## 💡 Особенности архитектуры

1. **Гибкое наследование** через композицию вместо классического наследования
2. **Автоматическая загрузка** компонентов из файловой структуры
3. **Строгая типизация** через интерфейсы
4. **Изоляция данных** через SessionData клонирование
5. **Кеширование** для оптимизации производительности

Эта архитектура обеспечивает масштабируемость, легкое добавление новых компонентов и чистую организацию кода.