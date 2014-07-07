USE `crnitalas`;
delimiter $$
CREATE PROCEDURE insertSve(naslov varchar(255),reditelj varchar(50),scenario  varchar(50),godina YEAR,trajanje int(3),zanr varchar(24),glumac varchar(50),uloga varchar(50),komentar text)
begin
-- ako postoji naziv filma u bazi dodeli varijabli @mid mid tog filma, ako ne postoji dodaj novi film @mid postavi na novi mid
-- po istom principu uradjeno je i sve ostalo
if (select count(mid) from filmovi where наслов=naslov and година=godina) then
	set @mid:=(select mid from filmovi where наслов=naslov and година=godina);
else 
	insert into filmovi (наслов,година,трајање,коментар) values (naslov,godina,trajanje,komentar);
	set @mid=(select max(mid) from filmovi);
end if;

if (select count(rid) from reditelji where редитељ=reditelj) then
	set @rid:=(select rid from reditelji where редитељ=reditelj);
else 
	insert into reditelji (редитељ) values (reditelj);
	set @rid:=(select max(rid) from reditelji);
end if;

if (select count(mid) from `mid-rid` where mid=@mid and rid=@rid)=0 then
	insert into `mid-rid` values (@mid,@rid);
end if;

if (select count(sid) from scenaristi where сценарио=scenario) then
	set @sid:=(select sid from scenaristi where сценарио=scenario);
else
insert into scenaristi (сценарио) values (scenario);
	set @sid:=(select max(sid) from scenaristi);
end if;

if (select count(mid) from `mid-sid` where mid=@mid and sid=@sid)=0 then
	insert into `mid-sid` values (@mid,@sid);
end if;

if (select count(gid) from glumci where глумац=glumac) then
	set @gid:=(select gid from glumci where глумац=glumac);
else
	insert into glumci (глумац) values (glumac);
	set @gid:=(select max(gid) from glumci);
end if;

if (select count(uid) from uloge where улога=uloga) then
	set @uid:=(select uid from uloge where улога=uloga);
else
	insert into uloge (улога) values (uloga);
	set @uid:=(select max(uid) from uloge);
end if;

if (select count(mid) from  `mid-gid-uid` where mid=@mid and gid=@gid and uid=@uid)=0 then
	insert into `mid-gid-uid` values (@mid,@gid, @uid);
end if;
if (select count(zid) from zanr where жанр=zanr) then
	set @zid:=(select zid from zanr where жанр=zanr);
else
	insert into zanr (жанр) values (zanr);
	set @zid:=(select max(zid) from zanr);
end if;

if (select count(mid) from `mid-zid` where mid=@mid and zid=@zid)=0 then
	insert into `mid-zid` values (@mid,@zid);
end if;
end$$
delimiter ;



-- provera da li u odredjenoj tabeli ima "otkacenih" (nepovezanih) unosa. Ako su se trigeri ukljucili procedura vraca prazan rezultat...
delimiter $$
CREATE PROCEDURE nadjiSlobodne(in fromTbl varchar(50), in leftJTbl varchar(50), in conID varchar(50))
begin
SET @s = CONCAT('SELECT f.', conID,'FROM ', fromTbl,  ' f left join ', leftJTbl, ' l on f.',conID, ' = l.', conID, ' where l.',conID,' is null'  );
PREPARE stmt1 FROM @s; 
EXECUTE stmt1; 
end $$
delimiter ;





USE `crnitalas`;

-- brise podatke u tabeli uloge koji su vezani za film koji se brise u tabeli filmovi
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `delFilm1` BEFORE DELETE ON `filmovi`
 FOR EACH ROW begin
delete 
from uloge
where uloge.uid in (
select m.uid 
from `mid-gid-uid` m 
where old.mid=m.mid
);
end

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
