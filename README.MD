- Baza crnitalas je baza filmova jugoslovenskog crnog talasa.
- Izvor podataka je Wikipedia.
- Ovo je bio pokusaj pravljenja izrazito normalizovane baze, gde se svaki (tekstualni) podatak pojavljuje samo jednom.

Fajlovi:
- Ista baza je izvezena dva puta jer mi se cini da PMA i Workbench ne izvoze na isti nacin:
	- crnitalas-MySqlWorkbench.sql
	- crnitalas-PMA.sql
- Procedure i triggeri
	- ProcedureITriggeri.sql

README.TXT


Osnovne tabele:

- filmovi
- glumci
- uloge
- reditelji 
- scenaristi
- zanr

Tabele veze (svaka ima foreign keys prema osnovnim tabelama i CASCADE on update i on delete, sto je i osnova za funkcionisanje triggera):

- mid-rid (filmovi-reditelji)
- mid-sid (filmovi-scenaristi)
- mid-zid (filmovi-zanr)
- mid-gid-uid (filmovi-glumci-uloge)

Views:

- broj_uloga (agregatni view koji pokazuje broj uloga odredjenog glumca (Bata je naravno prvi!))
- glumac_uloga
- ids (pomocni view za view sve)
- sve (svi podaci u bazi. Planirano je da taj view bude dominanti za delete, insert i update, ali tek na kraju sam shvatio cinjenicu da MySql ne podrzava trigger tip INSTEAD OF, tako da sam morao da odustanem od tog pristupa)
- bezglumaca (sve bez glumaca)

Stored Procedures:
- prikazi (procedura zamisljena kao pomocna i kao test procedura. Unese se naziv tabele i procedura prikaze sve iz tabele. Nije preterano razvijeno.)
	-- test
	call prikazi("glumci");

- insertSve (procedura olaksava unos kompletnih podataka vezanih za jedan film. Ako film ima vise glumaca, scenarista, u novom pozivu procedure menja se samo taj deo. Film ce biti samo jedno unet, a njegov id bice vezan za nove podatke.)
	-- model
	CALL `crnitalas`.`insertSve`(<{naslov varchar(255)}>, <{reditelj varchar(50)}>, <{scenario  varchar(50)}>, <{godina YEAR}>, <{trajanje int(3)}>, <{zanr varchar(24)}>, <{glumac varchar(50)}>, <{uloga varchar(50)}>, <{komentar text}>);


	-- test za proceduru insertSve.
	call insertSve("mbnf", "mcps", "ja", 1987, 45, "cudni", "on", "ti","no com");
	call insertSve("mbnf", "mcps", "ti", 1987, 45, "cudni", "ono", "taj","no com");

- nadjiSlobodne (provera da li u odredjenoj tabeli ima "otkacenih" (nepovezanih) unosa. Ako su se trigeri ukljucili procedura vraca prazan rezultat...)

	--model 
	CALL `crnitalas`.`nadjiSlobodne`(<{in fromTbl varchar(50)}>, <{in leftJTbl varchar(50)}>, <{in conID varchar(50)}>);
	-- test
	CALL `crnitalas`.`nadjiSlobodne`("glumci", "`mid-gid-uid`", "gid");

Triggers (triggeri su zamisljeni kao mehanizam koji brise kroz sve povezane tabele posle brisanja filma (cascade brise iz tabela veze, a triggeri koriste to kao podatak za brisanje iz osnovnih tabela)):


- `delFilm1` BEFORE DELETE ON `filmovi` (brise podatke u tabeli uloge koji su vezani za film koji se brise u tabeli filmovi)

uvezani triggeri
-- uvezani triggeri
-- posle brisanja u tabeli filmovi trigg se aktivira i pronalazi sve 'otkacene glumce' (glumce koji vise nisu vezani ni za jedan film) i brise ih
delimiter $$
CREATE TRIGGER brisiOtkaceneGlumce
after delete on filmovi
for EACH ROW
begin 
delete from glumci
where gid not in (select gid from `mid-gid-uid`);
end$$
delimiter ;

-- posle brisanja u tabeli glumci trigg se aktivira i pronalazi sve 'otkacene reditelje' (reditelje koji vise nisu vezani ni za jedan film) i brise ih
delimiter $$
CREATE TRIGGER brisiOtkaceneReditelje
after delete on glumci
for EACH ROW
begin 
delete from reditelji
where rid not in (select rid from `mid-rid`);
end$$
delimiter ;

-- posle brisanja u tabeli glumci trigg se aktivira i pronalazi sve 'otkacene reditelje' (reditelje koji vise nisu vezani ni za jedan film) i brise ih
delimiter $$
CREATE TRIGGER brisiOtkaceneScenariste
after delete on reditelji
for EACH ROW
begin 
delete from scenaristi
where sid not in (select sid from `mid-sid`);
end$$
delimiter ;



