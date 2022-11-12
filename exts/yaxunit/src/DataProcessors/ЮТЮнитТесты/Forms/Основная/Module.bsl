//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2022 BIA-Technologies Limited Liability Company
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//©///////////////////////////////////////////////////////////////////////////©//

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АдресХранилища") И ЭтоАдресВременногоХранилища(Параметры.АдресХранилища) Тогда
		
		ОтобразитьРезультатыТестирования(Параметры.АдресХранилища);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыДеревоТестов

&НаКлиенте
Процедура ДеревоТестовПриАктивизацииСтроки(Элемент)
	
	Данные = Элементы.ДеревоТестов.ТекущиеДанные;
	
	Если Данные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Данные.Ошибки.Количество() Тогда
		Элементы.ДеревоТестовОшибки.ТекущаяСтрока = Данные.Ошибки[0].ПолучитьИдентификатор();
	КонецЕсли;
	
	ОбновитьДоступностьСравнения();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыДеревоТестовОшибки

&НаКлиенте
Процедура ДеревоТестовОшибкиПриАктивизацииСтроки(Элемент)
	
	ОбновитьДоступностьСравнения();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Сравнить(Команда)
	
	Данные = Элементы.ДеревоТестовОшибки.ТекущиеДанные;
	
	Если Данные = Неопределено Или ПустаяСтрока(Данные.ОжидаемоеЗначение) И ПустаяСтрока(Данные.ФактическоеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура("ОжидаемоеЗначение, ФактическоеЗначение", Данные.ОжидаемоеЗначение, Данные.ФактическоеЗначение);
	ОткрытьФорму("Обработка.ЮТЮнитТесты.Форма.Сравнение", ПараметрыФормы, ЭтотОбъект, , , , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура СформироватьНастройки(Команда)
	
	ОткрытьФорму("Обработка.ЮТЮнитТесты.Форма.СозданиеНастройки", , ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОтобразитьРезультатыТестирования(АдресХранилища)
	
	Данные = ПолучитьИзВременногоХранилища(АдресХранилища);
	УдалитьИзВременногоХранилища(АдресХранилища);
	
	РезультатТестирования = Данные.РезультатыТестирования;
	Статусы = ЮТФабрика.СтатусыИсполненияТеста();
	
	ОбщаяСтатистика = Статистика();
	
	Для Каждого Набор Из РезультатТестирования Цикл
		
		СтрокаНабора = ДеревоТестов.ПолучитьЭлементы().Добавить();
		СтрокаНабора.Набор = Истина;
		СтрокаНабора.Представление = Набор.Представление;
		СтрокаНабора.Контекст = НормализоватьКонтекст(Набор.Режим);
		СтрокаНабора.ПредставлениеВремяВыполнения = ЮТОбщий.ПредставлениеПродолжительности(Набор.Длительность);
		СтрокаНабора.ВремяВыполнения = Набор.Длительность / 1000;
		СтрокаНабора.ТипОбъекта = 2;
		
		ЗаполнитьОшибки(СтрокаНабора, Набор);
		
		СтатистикаНабора = Статистика();
		
		Для Каждого Тест Из Набор.Тесты Цикл
			
			СтрокаТеста = СтрокаНабора.ПолучитьЭлементы().Добавить();
			СтрокаТеста.Представление = Тест.Имя;
			СтрокаТеста.Контекст = НормализоватьКонтекст(Набор.Режим);
			СтрокаТеста.ПредставлениеВремяВыполнения = ЮТОбщий.ПредставлениеПродолжительности(Тест.Длительность);
			СтрокаТеста.ВремяВыполнения = Тест.Длительность / 1000;
			СтрокаТеста.Состояние = Тест.Статус;
			СтрокаТеста.ТипОбъекта = 3;
			
			СтрокаТеста.Иконка = КартинкаСтатуса(Тест.Статус);
			ЗаполнитьОшибки(СтрокаТеста, Тест);
			ИнкрементСтатистики(СтатистикаНабора, Тест.Статус, Статусы);
			
		КонецЦикла;
		
		Если СтатистикаНабора.Сломано Тогда
			СтрокаНабора.Состояние = Статусы.Сломан;
		ИначеЕсли СтатистикаНабора.Упало Тогда
			СтрокаНабора.Состояние = Статусы.Ошибка;
		ИначеЕсли СтатистикаНабора.Пропущено Тогда
			СтрокаНабора.Состояние = Статусы.Пропущен;
		ИначеЕсли СтатистикаНабора.Неизвестно Тогда
			СтрокаНабора.Состояние = Статусы.Ошибка;
		Иначе
			СтрокаНабора.Состояние = Статусы.Успешно;
		КонецЕсли;
		
		СтрокаНабора.Прогресс = ГрафическоеПредставлениеСтатистики(СтатистикаНабора);
		
		СтрокаНабора.Иконка = КартинкаСтатуса(СтрокаНабора.Состояние);
		
		Для Каждого Элемент Из СтатистикаНабора Цикл
			ЮТОбщий.Инкремент(ОбщаяСтатистика[Элемент.Ключ], Элемент.Значение);
		КонецЦикла;
		
	КонецЦикла;
	
	Элементы.СтатистикаВыполнения.Заголовок = ПредставлениеСтатистики(ОбщаяСтатистика);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗаполнитьОшибки(СтрокаДерева, ОписаниеОбъекта)
	
	Для Каждого Ошибка Из ОписаниеОбъекта.Ошибки Цикл
		
		СтрокаОшибки = СтрокаДерева.Ошибки.Добавить();
		СтрокаОшибки.Сообщение = Ошибка.Сообщение;
		СтрокаОшибки.Стек = Ошибка.Стек;
		СтрокаОшибки.ОжидаемоеЗначение = ЮТОбщий.ЗначениеСтруктуры(Ошибка, "ОжидаемоеЗначение");
		СтрокаОшибки.ФактическоеЗначение = ЮТОбщий.ЗначениеСтруктуры(Ошибка, "ПроверяемоеЗначение");
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция Статистика()
	
	Статистика = Новый Структура();
	Статистика.Вставить("Всего", 0);
	Статистика.Вставить("Успешно", 0);
	Статистика.Вставить("Упало", 0);
	Статистика.Вставить("Сломано", 0);
	Статистика.Вставить("Пропущено", 0);
	Статистика.Вставить("Неизвестно", 0);
	
	Возврат Статистика;
	
КонецФункции

&НаСервереБезКонтекста
Функция НормализоватьКонтекст(Контекст)
	
	Если СтрНачинаетсяС(Контекст, "Клиент") Тогда
		Возврат "Клиент";
	Иначе
		Возврат Контекст;
	КонецЕсли;
	
КонецФункции

&НаСервереБезКонтекста
Процедура ИнкрементСтатистики(Статистика, Статус, Знач Статусы = Неопределено)
	
	Если Статусы = Неопределено Тогда
		Статусы = ЮТФабрика.СтатусыИсполненияТеста();
	КонецЕсли;
	
	ЮТОбщий.Инкремент(Статистика.Всего);
	
	Если Статус = Статусы.Успешно Тогда
		
		ЮТОбщий.Инкремент(Статистика.Успешно);
		
	ИначеЕсли Статус = Статусы.Сломан ИЛИ Статус = Статусы.НеРеализован Тогда
		
		ЮТОбщий.Инкремент(Статистика.Сломано);
		
	ИначеЕсли Статус = Статусы.Ошибка Тогда
		
		ЮТОбщий.Инкремент(Статистика.Упало);
		
	ИначеЕсли Статус = Статусы.Пропущен Тогда
		
		ЮТОбщий.Инкремент(Статистика.Пропущено);
		
	Иначе
		
		ЮТОбщий.Инкремент(Статистика.Неизвестно);
		
	КонецЕсли;
	
КонецПроцедуры

#Область Интерфейсное

&НаСервереБезКонтекста
Функция КартинкаСтатуса(Статус)
	
	Статусы = ЮТФабрика.СтатусыИсполненияТеста();
	
	Если Статус = Статусы.Успешно Тогда
		
		Возврат БиблиотекаКартинок.ЮТУспешно;
		
	ИначеЕсли Статус = Статусы.Сломан ИЛИ Статус = Статусы.НеРеализован Тогда
		
		Возврат БиблиотекаКартинок.ЮТОшибка;
		
	ИначеЕсли Статус = Статусы.Ошибка Тогда
		
		Возврат БиблиотекаКартинок.ЮТУпал;
		
	ИначеЕсли Статус = Статусы.Пропущен Тогда
		
		Возврат БиблиотекаКартинок.ЮТПропущен;
		
	Иначе
		
		Возврат БиблиотекаКартинок.ЮТНеизвестный;
		
	КонецЕсли;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПредставлениеСтатистики(Статистика)
	
	БлокиСтатистики = Новый Массив();
	Разделитель = ";    ";
	
	БлокиСтатистики.Добавить(СтрШаблон("Тестов: %1/%2", Статистика.Всего, Статистика.Всего - Статистика.Пропущено));
	
	Если Статистика.Пропущено Тогда
		БлокиСтатистики.Добавить(Разделитель);
		БлокиСтатистики.Добавить(БиблиотекаКартинок.ЮТПропущен);
		БлокиСтатистики.Добавить(" Пропущено: " + Статистика.Пропущено);
	КонецЕсли;
	
	БлокиСтатистики.Добавить(Разделитель);
	БлокиСтатистики.Добавить(БиблиотекаКартинок.ЮТУспешно);
	БлокиСтатистики.Добавить(" Успешно: " + Статистика.Успешно);
	
	БлокиСтатистики.Добавить(Разделитель);
	БлокиСтатистики.Добавить(БиблиотекаКартинок.ЮТОшибка);
	БлокиСтатистики.Добавить(" Сломано: " + Статистика.Сломано);
	
	БлокиСтатистики.Добавить(Разделитель);
	БлокиСтатистики.Добавить(БиблиотекаКартинок.ЮТУпал);
	БлокиСтатистики.Добавить(" Упало: " + Статистика.Упало);
	
	Если Статистика.Неизвестно Тогда
		БлокиСтатистики.Добавить(Разделитель);
		БлокиСтатистики.Добавить(БиблиотекаКартинок.ЮТНеизвестный);
		БлокиСтатистики.Добавить(" Неизвестно: " + Статистика.Неизвестно);
	КонецЕсли;
	
	Возврат Новый ФорматированнаяСтрока(БлокиСтатистики);
	
КонецФункции

&НаСервереБезКонтекста
Функция ГрафическоеПредставлениеСтатистики(Статистика)
	
	Текст = БлокиСтатистики(Статистика);
	
	Возврат Новый Картинка(ПолучитьДвоичныеДанныеИзСтроки(Текст));
	
КонецФункции

&НаСервереБезКонтекста
Функция БлокиСтатистики(Статистика)
	
	Блоки = Новый Массив();
	Блоки.Добавить(Новый Структура("Количество, Цвет", Статистика.Успешно, "25AE88"));
	Блоки.Добавить(Новый Структура("Количество, Цвет", Статистика.Пропущено, "999999"));
	Блоки.Добавить(Новый Структура("Количество, Цвет", Статистика.Упало, "EFCE4A"));
	Блоки.Добавить(Новый Структура("Количество, Цвет", Статистика.Сломано, "D75A4A"));
	Блоки.Добавить(Новый Структура("Количество, Цвет", Статистика.Неизвестно, "9400d3"));
	
	Сдвиг = 0;
	Высота = 20;
	
	Текст = "";
	
	Для Инд = 0 По Блоки.ВГраница() Цикл
		
		Если Блоки[Инд].Количество = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Текст = Текст + СтрШаблон("	<rect x=""%1"" y=""2"" width=""%2"" height=""%3"" rx=""4"" ry=""4"" style=""fill:none;stroke:#%4;stroke-width:2""/>
								  |	<text x=""%5"" y=""%6"" dominant-baseline=""middle"" text-anchor=""middle"" style=""fill:#%4;"">%7</text>
								  |", Сдвиг + 2, Высота * 2 - 4, Высота - 4, Блоки[Инд].Цвет, Сдвиг + Высота, Высота - 4, Блоки[Инд].Количество);
		ЮТОбщий.Инкремент(Сдвиг, Высота * 2 + 2);
		
	КонецЦикла;
	
	Возврат СтрШаблон("<svg version=""1.1"" xmlns=""http://www.w3.org/2000/svg"" xmlns:xlink=""http://www.w3.org/1999/xlink"" x=""0px"" y=""0px"" width=""%1px"" height=""%2px""
					  |	 viewBox=""0 0 %1 %2"">
					  |	%3
					  |</svg>", Сдвиг, Высота + 2, Текст);
	
КонецФункции

#КонецОбласти

&НаКлиенте
Процедура ОбновитьДоступностьСравнения()
	
	Данные = Элементы.ДеревоТестовОшибки.ТекущиеДанные;
	Элементы.Сравнить.Доступность = Данные <> Неопределено И (НЕ ПустаяСтрока(Данные.ОжидаемоеЗначение) Или НЕ ПустаяСтрока(Данные.ФактическоеЗначение));
	
КонецПроцедуры

#КонецОбласти
