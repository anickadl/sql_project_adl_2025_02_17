Můj projekt z SQL
---

Zdravím všechny, kdo si zrovna čtou můj projekt. Můj projekt se skládá z následujících skriptů:

- Project
- Project_otazky

V první řadě jsem si vytvořila datový podklad, který sestává z dvou tabulek. Tyto tabulky jsem vytvořila z datových sad, kterými jsou:

- czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
- czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
- czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
- czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
- czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
- czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
- czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.
- czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
- czechia_district – Číselník okresů České republiky dle normy LAU.
- countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
- economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

První tabulku jsem vytvořila spojením všech dostupných tabulek a číselníků, kromě tabulek countries a economies, ty jsem použila později. Nevyužila jsem ani tabulky czechia_region a czechia_district, protože mi stačilo pracovat s hodnotami pro celou republiku a nerozlišovat ji na kraje a okresy. Tabulku jsem spojila přes všechny kódy v číselnících. Jelikož jsem ze zadaných úkolů věděla, že budu pracovat pouze se mzdami, vyfiltrovala jsem data pomocí where, aby se data týkala pouze mezd a v hodnotě Kč. Následně jsem si i zkontrolovala, jestli ve sloupci industry_branch_name nejsou nulové hodnoty. Zjistila jsem, že ano, pravděpodobně týkající se mezd za celou republiku. K práci potřebuji znát mzdy pouze za odvětví, takže jsem i toto ošetřila, abych neměla zkreslené výsledky. V původní tabulce czechia_payroll se průměrné mzdy zobrazují po kvartálech, v podselektu wages_yearly v CTE jsem proto tyto mzdy zprůměrovala, abych  měla pouze průměrnou mzdu za odvětví a rok, nikoliv za kvartál.

Druhou tabulku jsem vytvářela spojením tabulek countries a economies. Po zhlédnutí, co obě tabulky obsahují za sloupce, jsem zjistila, že obsahují sloupce jako population a country. Nakonec při joinování jsem tabulky spárovala jen pomocí country, protože sloupec population v tabulce countries obsahuje pravděpodobně nějakou obecnou populaci, neboť v této tabulce nejsou hodnoty uváděny za jednotlivé roky. Dále jsem potřebovala propojit tabulku primary a secondary, aby obě tabulky byly za stejné časové obodbí. Proto jsem spojila i tyto dvě tabulky spolu přes sloupec rok.

Jelikož první tabulka obsahovala jen číselníky pro kraje a okresy, ošetřila jsem případné spojení těchto dvou tabulek ještě přidáním sloupce state do primarní tabulky.

## Výsledky

Na základě mého vytvořeného datového podkladu jsem mohla zodpověděť na výzkumné otázky.

### 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Na základě připravené primary tabulky, kde jsem měla připravené průměrné mzdy za odvětví a rok, stačilo pouze porovnat mzdu u každého odvětví se mzdou následující rok. Abych zjistila mzdu za následující rok, použila jsem k tomu funkci LAG. Jelikož v primary tabulce jsou hodnoty year, industry_branch_name a avg_monthly_wage znásobené, kvůli tomu, že každý řádek je i pro produkt a jeho cenu v daném roce, musela jsem zde udělat opět průměr mezd za daný rok a dané odvětví, jinak bych hodnoty měla zdvojené přesně tak jak v primary tabulce. Protože by to select jinak nesesumíroval. Výsledkem je pocet_poklesu, který vrací počet let, ve kterých mzdy v porovnání s předchozím rokem klesly. Druhý je textový řetezec, který vypíše roky, ve kterých k poklesu došlo. Po spuštění dotazu se ukázalo, že pouze ve třech odvětvích k poklesu nedošlo, u všech ostatních ano. 

### 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

Prvně jsem si zjistila, jak se chléb a mléko v datech nazývá. Následně jsem zjistila, jaké je první a poslední srovnatelné období, ve kterém se vyskytuje hledaný chléb a mléko
V prvním srovnatelném období je možné si koupit 1313 kg chleba a 1466 l mléka. V posledním srovnatelném období si lze koupit 1365 kg chleba a 1670 l mléka.

### 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Nejpomaleji zdražuje Cukr krystalový, a to o necelé 2 %.


### 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Neexistuje takový rok, při zadaných podmínkách se nevypíše žádný výsledek. Nejvyšší meziroční nárůst byl v roce 2013 o 6,59 %. K tomuto zjištění jsem si vytvořila další podmínku a jedno řazení, abych zjistila, který meziroční nárůst byl tedy největší, když víc jak 10 % nikdy nebyl.

### 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

V pátém úkolu jsem si nejprve rozdělila výpočet do menších částí pomocí CTE, kde jsem si samostatně připravila průměrné roční hodnoty a následně z nich dopočítala procentní meziroční růsty pomocí funkce LAG. V dalších CTE jsem tedy měla zvlášť procentní růst cen, procentní růst mezd a procentní růst HDP. V konečném CTE jsem pak tyto výsledky spojila a pomocí funkce LEAD jsem si k aktuálnímu roku zobrazila i hodnoty pro následující rok, abych měla možnost srovnání. Poté jsem chtěla výsledky vyfiltrovat pouze na roky, ve kterých došlo k výraznějšímu růstu HDP. V této fázi jsem zjistila, že pokud použiji klauzuli WHERE přímo spolu s funkcí LEAD, dojde ke kolizi, protože LEAD se počítá už jen z vyfiltrované podmnožiny. Abych tomu předešla, vytvořila jsem kompletní výsledek v CTE pod názvem final a teprve nad ním jsem aplikovala filtr WHERE, čímž jsem zajistila, že hodnoty následujícího roku odpovídají skutečným hodnotám z celé časové řady. Při volbě hranice pro výraznější růst HDP jsem nejprve nastavila hodnotu 10 % jako v předchozím úkolu, ale tato podmínka mi nevrátila žádný záznam. Proto jsem hranici snížila na 5 %, což už výsledky vrátilo. V těchto výsledcích bylo vidět, že v roce 2015 při růstu HDP ceny klesly a tento pokles pokračoval i v následujícím roce. V roce 2017 ceny sice vzrostly, ale ve srovnání s následujícím rokem opět klesly. Jako alternativní řešení jsem do jednoho z CTE přidala podselect, který mi spočítal průměrný procentní růst HDP, a tuto hodnotu jsem použila jako hranici pro vyhodnocení výraznějšího růstu, proto je v kódu použitý filtr WHERE dvakrát. Je to z toho důvodu, že jsem nevěděla jak nastavit "výraznější růst HDP".

