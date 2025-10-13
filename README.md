Můj projekt z SQL
---

Zdravím všechny, kdo si zrovna čtou můj projekt. Tento projekt vznikl jako součást studia datové analýzy a jeho cílem bylo analyzovat vývoj mezd a cen základních potravin v České republice v letech 2006–2018 a zjistit, zda mezi nimi existuje vztah.

# Projekt se skládá z:
- tables
- questions

## Práce na projektu

V první řadě jsem si vytvořila datový podklad, který sestává z dvou tabulek. Tyto tabulky jsem vytvořila z datových sad, kterými jsou:

- `czechia_payroll` – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
- `czechia_payroll_calculation` – Číselník kalkulací v tabulce mezd.
- `czechia_payroll_industry_branch` – Číselník odvětví v tabulce mezd.
- `czechia_payroll_unit` – Číselník jednotek hodnot v tabulce mezd.
- `czechia_payroll_value_type` – Číselník typů hodnot v tabulce mezd.
- `czechia_price` – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
- `czechia_price_category` – Číselník kategorií potravin, které se vyskytují v našem přehledu.
- `czechia_region` – Číselník krajů České republiky dle normy CZ-NUTS 2.
- `czechia_district` – Číselník okresů České republiky dle normy LAU.
- `countries` - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
- `economies` - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

## Tvorba datového podkladu

### Primary tabulka

**Postup:**
První tabulku jsem vytvořila spojením všech dostupných tabulek a číselníků, kromě tabulek countries a economies, ty jsem použila později. Nevyužila jsem ani tabulky czechia_region a czechia_district, protože mi stačilo pracovat s hodnotami pro celou republiku a nerozlišovat ji na kraje a okresy. Tabulku jsem spojila přes všechny kódy v číselnících. Jelikož jsem ze zadaných úkolů věděla, že budu pracovat pouze se mzdami, vyfiltrovala jsem data pomocí where, aby se data týkala pouze mezd a v hodnotě Kč. Následně jsem si i zkontrolovala, jestli ve sloupci industry_branch_name nejsou nulové hodnoty. Zjistila jsem, že ano, pravděpodobně týkající se mezd za celou republiku. K práci potřebuji znát mzdy pouze za odvětví, takže jsem i toto ošetřila, abych neměla zkreslené výsledky. V původní tabulce czechia_payroll se průměrné mzdy zobrazují po kvartálech, v podselektu wages_yearly v CTE jsem proto tyto mzdy zprůměrovala, abych  měla pouze průměrnou mzdu za odvětví a rok, nikoliv za kvartál.


---

### Secondary tabulka

**Postup:**
Druhou tabulku jsem vytvářela spojením tabulek countries a economies. Po zhlédnutí, co obě tabulky obsahují za sloupce, jsem zjistila, že obsahují sloupce jako population a country. Nakonec při joinování jsem tabulky spárovala jen pomocí country, protože sloupec population v tabulce countries obsahuje pravděpodobně nějakou obecnou populaci, neboť v této tabulce nejsou hodnoty uváděny za jednotlivé roky. Dále jsem potřebovala propojit tabulku primary a secondary, aby obě tabulky byly za stejné časové obodbí. Proto jsem spojila i tyto dvě tabulky spolu přes sloupec rok.

Jelikož první tabulka obsahovala jen číselníky pro kraje a okresy, ošetřila jsem případné spojení těchto dvou tabulek ještě přidáním sloupce state do primarní tabulky.

## Výsledky

Na základě mého vytvořeného datového podkladu jsem mohla zodpověděť na výzkumné otázky.

### 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

**Postup:**  
Z primary tabulky jsem použila průměrné roční mzdy podle odvětví. Pomocí funkce `LAG()` jsem porovnávala mzdu v aktuálním roce s rokem předchozím.  
Protože tabulka obsahovala více záznamů pro každý rok (kvůli spojení s cenami), musela jsem znovu spočítat průměr mezd za rok a odvětví, abych předešla duplicitám.

**Odpověď a zhodnocení:**   

Analýza ukázala, že pouze ve třech odvětvích nedošlo během sledovaného období k poklesu mezd – konkrétně v odvětvích `Ostatní činnosti`, `Zdravotní a sociální péče` a `Zpracovatelský průmysl`. Ve všech ostatních odvětvích se alespoň v jednom roce projevil meziroční pokles průměrné mzdy. Nejčastější poklesy byly zaznamenány v odvětví `Těžba a dobývání`, kde mzdy klesly celkem čtyřikrát (v letech 2009, 2013, 2014 a 2016). Druhým nejvíce kolísavým odvětvím byla `Výroba a rozvod elektřiny, plynu, tepla a klimatizovaného vzduchu`, kde se mzdy snížily třikrát – v letech 2011, 2013 a 2015.

I když většina odvětví dlouhodobě vykazuje růst mezd, v některých se jejich vývoj v jednotlivých letech kolísá.
---


### 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?


**Postup:**  
Zjistila jsem názvy položek *chléb* a *mléko* v datasetu a určila první a poslední období, kdy se obě potraviny vyskytují.  
Pro každý rok jsem vypočítala, kolik jednotek potraviny lze koupit za průměrnou mzdu.

**Odpověď a zhodnocení:**  
- **2006:** 1313 kg chleba nebo 1466 l mléka  
- **2018:** 1365 kg chleba nebo 1670 l mléka  

Z porovnání vychází, že mléko mezi lety 2006 a 2018 zdražovalo pomaleji než chleba a také pomaleji než rostly mzdy.

Zatímco u chleba se množství, které bylo možné za průměrnou mzdu koupit, zvýšilo jen nepatrně (z 1313 kg na 1365 kg), u mléka byl nárůst výraznější – z 1466 litrů na 1670 litrů.

To znamená, že lidé si mohli dovolit víc mléka než dřív, protože mzdy rostly rychleji než jeho cena. Mléko tedy ve srovnání s výdělky zlevnilo, zatímco chleba zdražoval rychleji.

---

### 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?


**Postup:**  
Pomocí funkce `LAG()` jsem spočítala meziroční procentní nárůst cen všech potravin.  
Následně jsem porovnala průměrné hodnoty nárůstu podle kategorií.

**Odpověď a zhodnocení:**  
Nejpomaleji zdražovaly `banány žluté,` a to o 0.81 % ročně. Naopak nejrychleji zdražovaly `papriky` a to o 7.29 %. Potraviny jako `cukr krystalový` a `rajská jablka červená kulatá` dokonce zlevňovaly.

---

### 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

**Postup:**  
Porovnala jsem meziroční změny mezd a cen potravin. Vytvořila jsem podmínku, která měla vrátit roky, kdy byl rozdíl větší než 10 %.

**Odpověď a zhodnocení:**  
Takový rok se nevyskytl – největší rozdíl byl v roce `2013 (6,65 %)`.  
Pro doplnění jsem zobrazila i přehled všech let s procentními nárůsty, aby byl trend viditelný.  

Z dat vyplývá, že mezi lety 2009 a 2018 se kupní síla obyvatel výrazně měnila – nejvíce vzrostla v roce 2013, zatímco nejvíce klesla v roce 2009 a znovu se zhoršila po roce 2014, kdy ceny začaly růst rychleji než mzdy.

---

### 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

**Postup:**  
Pomocí CTE jsem vypočítala meziroční růst HDP, mezd a cen potravin. Funkcí `LEAD()` jsem přidala hodnoty následujícího roku, abych mohla sledovat zpožděný dopad růstu HDP. Při volbě hranice pro výraznější růst HDP jsem nejprve nastavila hodnotu 10 % jako v předchozím úkolu, ale tato podmínka mi nevrátila žádný záznam. Proto jsem hranici snížila na 5 %, což už výsledky vrátilo. Jako alternativní řešení jsem do jednoho z CTE přidala podselect, který mi spočítal průměrný procentní růst HDP, a tuto hodnotu jsem použila jako hranici pro vyhodnocení výraznějšího růstu.

**Odpověď a zhodnocení:**
Z výsledků je patrné, že pokud dojde k výraznějšímu růstu HDP, projeví se to i v růstu mezd a s menším odstupem také v růstu cen. V roce 2007 se vyšší růst HDP odrazil v rostoucích mzdách i cenách, zatímco v roce 2015, kdy byl růst pomalejší, mzdy rostly jen mírně a ceny dokonce klesly. V roce 2017 se s opětovným zrychlením růstu HDP zvedly i mzdy a následně i ceny. Dá se tedy říct, že výrazný růst HDP má pozitivní dopad na mzdy a s časovým zpožděním také na celkovou cenovou hladinu.



