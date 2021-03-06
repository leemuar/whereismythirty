﻿
// Возвращает скидку на указанную номенклатуру
//
// Параметры:
//  Номенклатура  - СправочникСсылка.Номенклатура - Номенклатура
//                 для которой требуется определить скидку
//
// Возвращаемое значение:
//   Число   - Скидка в процентах. 0 если скидка не определена
//
Функция ПолучитьСкидкуНоменклутуры(Знач Номенклатура) Экспорт

	// по умолчанию скидка 0 
	Скидка = 0;
	
	// можно было бы написать универсальный алгоритм
	// рассчета скидки для любой глубины иерархии справочника.
	// Но для конкретно этой конфигурации и задачи при фиксированном
	// уровне макс иерархии (5) проще и оптимальнее будет получить
	// одним простым запросом с левыми соединениями
	//
	// Использовать группировку по иерархии для одного элемента не рекомендуется:
	// https://its.1c.ru/db/content/metod8dev/src/developers/platform/metod/query/i8102659.htm
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Номенклатура.Скидка КАК СкидкаТовар,
	|	Номенклатура.Родитель.Скидка КАК СкидкаГруппа1,
	|	Номенклатура.Родитель.Родитель.Скидка КАК СкидкаГруппа2,
	|	Номенклатура.Родитель.Родитель.Родитель.Скидка КАК СкидкаГруппа3,
	|	Номенклатура.Родитель.Родитель.Родитель.Родитель.Скидка КАК СкидкаГруппа4
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.Ссылка = &Номенклатура";
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	РезультатЗапроса = Запрос.Выполнить();
	// объект выборки не имеет итератора по колонкам (нельзя пройти в цикле
	// Для Каждого по всем колонкам), но есть возможность получать значение
	// колонки по индексу. Для этого запомним индекс последней колонки,
	// чтобы позже организовать цикл по колонкам выборки
	ИндексПоследнейКолонки = РезультатЗапроса.Колонки.Количество() - 1;
	Выборка = РезультатЗапроса.Выбрать();
	Если Выборка.Следующий() Тогда
		// цикл по всем колонкам выборки начиная с первой
		Для ИндексКолонки = 0 По ИндексПоследнейКолонки Цикл
			// скидка указана?
			Если 0 <> Выборка[ИндексКолонки] Тогда
				Скидка = Выборка[ИндексКолонки];
				Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат Скидка;

КонецФункции