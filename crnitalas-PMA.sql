-- phpMyAdmin SQL Dump
-- version 3.5.2.2
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Apr 15, 2014 at 01:12 PM
-- Server version: 5.5.27
-- PHP Version: 5.4.7

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `crnitalas`
--
CREATE DATABASE `crnitalas` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `crnitalas`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`umbra`@`%` PROCEDURE `insertSve`(naslov varchar(255),reditelj varchar(50),scenario  varchar(50),godina YEAR,trajanje int(3),zanr varchar(24),glumac varchar(50),uloga varchar(50),komentar text)
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

CREATE DEFINER=`umbra`@`%` PROCEDURE `nadjiSlobodne`(in fromTbl varchar(50), in leftJTbl varchar(50), in conID varchar(50))
begin
SET @s = CONCAT('SELECT f.', conID,' FROM ', fromTbl,  ' f left join ', leftJTbl, ' l on f.',conID, ' = l.', conID, ' where l.',conID,' is null'  );
PREPARE stmt1 FROM @s; 
EXECUTE stmt1; 
end$$

CREATE DEFINER=`umbra`@`%` PROCEDURE `prikazi`(in fil varchar(50))
begin
SET @s = CONCAT('SELECT * FROM ', fil);

PREPARE stmt1 FROM @s; 
EXECUTE stmt1; 
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `безглумаца`
--
CREATE TABLE IF NOT EXISTS `безглумаца` (
`наслов` varchar(255)
,`редитељ` varchar(46)
,`сценарио` varchar(46)
,`година` year(4)
,`трајање` int(3) unsigned
,`жанр` varchar(24)
,`коментар` text
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `broj_uloga`
--
CREATE TABLE IF NOT EXISTS `broj_uloga` (
`глумац` varchar(46)
,`број_улога` bigint(21)
,`Од` year(4)
,`До` year(4)
);
-- --------------------------------------------------------

--
-- Table structure for table `filmovi`
--

CREATE TABLE IF NOT EXISTS `filmovi` (
  `mID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `наслов` varchar(255) CHARACTER SET utf8 NOT NULL,
  `година` year(4) NOT NULL,
  `трајање` int(3) unsigned NOT NULL,
  `коментар` text CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`mID`),
  UNIQUE KEY `mid_in` (`mID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Табела са наслови' AUTO_INCREMENT=20 ;

--
-- Dumping data for table `filmovi`
--

INSERT INTO `filmovi` (`mID`, `наслов`, `година`, `трајање`, `коментар`) VALUES
(1, 'Биће скоро пропаст света', 1968, 84, 'У једном војвођанском селу кафеџија је у свађи са свињарем. Да би му се осветио, кафеџија са друговима наговори полупијаног свињара да се ожени сеоском лудом. У међувремену, у село долази млада учитељица у коју се свињар заљуби. Мислећи да му сада жена смета, он је убије. Његов отац прима кривицу на себе, али, временом, сељаци открију правог убицу, намаме га у звоник, вежу га међу звона и свињар умире растргнут'),
(2, 'Буђење пацова', 1967, 79, 'Филм говори о неуспелом покушају једног усамљеника да измени свој бесмислени живот. Трагајући за послом и новцем, заљубљује се у непознату девојку за коју верује да представља прекретницу у његовом животу. И када његова илузија о срећи достигне врхунац, девојка кришом одлази са његовим, од познаника добијеним новцем, остављајући га разочараног и превареног где је био пре овог сусрета'),
(3, 'Вране', 1969, 76, 'Филм говори о остарелом боксеру који како би од нечега живео, почиње да се бави сумњивим пословима са сумњивим људима који пљачкају, краду, тумарају.'),
(4, 'Заседа', 1969, 80, 'Заседа је југословенски играни филм из 1969. године. Режирао га је Живојин Павловић који је написао и сценарио по мотивима властите приповјетке „Легенде“ и проповјетке „По трећи пут“ Антонија Исаковића. Спада у остварења црног таласа.'),
(5, 'И Бог створи кафанску певацицу', 1972, 0, ''),
(6, 'Јутро', 1967, 84, 'Рат је оставио дубоке трагове у људима. Пролазећи кроз различите сукобе првих дана мира и обрачунавања са бившим сарадницима окупатора и стрељања издајника, а некадашњи ратник открива да и мир није без убијања. ['),
(7, 'Кад будем мртав и бео', 1967, 79, 'Јанко Бугарски, звани Џими Барка, мора да напусти заједно са својом девојком Лилицом привремено запослење као сезонски радник. Без посла, креће са Лилицом у неизвесност. Мајка, сиромашна праља, не може да му помогне, а у фабрикама и предузећима нема места. Да би дошао до пара, Џими поткрада раднике на једном градилишту и бежећи од гонилаца, изгуби Лилицу. Тада започиње одисеја Џимија Барке. Среће кафанску певачицу, Душку, постаје њен љубавник и учи да пева. Пева веома рђаво, али то му не смета да путује по варошицама, пева на вашарима и по забаченим војним гарнизонима. У једној варошици среће младу зуботехничарку Бојану, и са њом одлази у Београд на такмичење младих певача. Уместо аплауза и афирмације, дочекују га звиждуци и увреде. Џими бежи сам и на једном броду поново среће Лилицу, која живи од џепарења и симулирања трудноће. Обоје одлазе код управника бившег градилишта Милутина, у покушају да га уцене: млада жена наводно носи његово дете. Милутин открива да су га преварили. Покушава да силује Лилицу, али га Џими спречава. Покушава да га убије и исмева га пред радницима. Понижени и изнервирани директор, узима своју пушку и убија Џимија.'),
(8, 'Љубавни случај или трагедија службенице ПТТ', 1967, 77, ''),
(9, 'Мајстор и Маргарита', 1972, 95, 'Радња филма се одвија у Москви, 1925. године. Писац Николај Максудов Маестро (у роману нема име, већ је само Маестро или Мајстор) је јавно осуђен од стране пролетерских писаца због драмског дела „Понтије Пилат“, а заказана премијера бива отказана. Пометњу у збивања уноси Сатана, са својим помоћницима. У најтежим тренуцима уз писца је Маргарета, жена коју воли.'),
(10, 'Мистерије организма', 1971, 86, 'Филм је сниман на локацијама у САД и Југославији у периоду од 1968. до 1971. Дио који је снимљен у САД је документарног карактера и бави се судбином Фројдовог ученика Вилхелма Рајха, чије су књиге одлуком америчког Федералног суда из 1954. проглашене илегалним и спаљене у присуству службених лица.[1] Између осталог, филм се бави питањима црвене буржоазије и секса. Химну за филм је написао и извео Булат Окуџава.'),
(11, 'Млад и здрав као ружа', 1971, 72, 'Млад и здрав као ружа је филм редитеља Јована Јовановића. Припада остварењима црног таласа. Снимљен је 1971. и говори о почецима везе српске државне безбедности и криминалаца. Готово читав је снимљен камером из руке, што даје утисак документарности и појачава драматику.'),
(12, 'Невиност без заштите', 1968, 79, 'Невиност без заштите је југословенски документарни филм из 1968. године. Режирао га је Душан Макавејев, који је написао и сценарио. Припада остварењима црног таласа.Направљен као колаж који се састоји од истоименог играног филма из 1942. године у режији Драгољуба Алексића, затим од документарних снимака акробатских наступа Драгољуба Алексића који су снимљени у периоду од 1929. до 1940, и од документарних снимака на којима се појављују актери филма Невиност без заштите из 1942. Колаж садржи и документарне снимке Београда након бомбардовања, Милана Недића, Димитрија Љотића, као и сахрану пуковникаМилоша Масаловића (посмртно унапређен у чин бригадног генерала). У филму су кориштени материјали Југословенске кинотеке. Пјесму о Алексићу изводи Војислав Костић на стихове Александра Поповића. Филм је имао проблеме са цензорима јер је главни глумац личио на Јосипа Броза.'),
(13, 'Пластични Исус', 1971, 73, 'Том долази у Београд да сними филм, али му то баш не полази за руком. Успут ступа у везу са неколико жена, од којих га једна, у наступу љубоморе, убија. Прилично тривијална радња, али је оно што се појављује око ње заправо суштина због које је филм сакривен од јавности, а редитељ допао затвора.'),
(14, 'Подне', 1968, 82, 'Филм говори о љубави између Руса који је службеник совјетске амбасаде и девојке из Југославије. Када се венчају одмах прве брачне ноћи радио јавља вест о сукобу између комунистичких партија њихових земаља. Та вест је значила растанак у којем има мало наде да ће се поново срести.'),
(15, 'Празник ', 1967, 83, ''),
(16, 'Рани радови', 1969, 87, 'Рани радови на алегоричан начин излажу причу младих учесника студентских демонстрација, јуна 1968. у Београду: три младића и дјевојка Југослава, супростављају се малограђанској рутини свакодневнице. У жељи да „промијене свијет“, надахнути текстовима младог Карла Маркса, одлазе у села и фабрике, да „пробуде свијест“ људи, да их охрабре у борби за еманципацију и достојанствен живот. У том боравку и раду на терену се суочавају са примитивизмом и биједом али и са сопственим ограничењима, слабостима, немоћи, љубомором. Бивају и хапшени. Фрустрирани што је планирана револуција неостварена, три младића одлучују да елиминишу Југославу, свједока њихове неспособности. Пуцају у њу, прекривају је партијском заставом, пале њено тијело, те од намјераване акције остаје таман стуб дима који се диже у небо.'),
(17, 'Скупљачи перја', 1967, 94, 'Радња филма се базира на животу Рома у једном селу на сјеверу Војводине, али филм се бави далеко сложенијим темама попут љубави, међуетничких и социјалних односа. Главне улоге тумаче Беким Фехмију, Оливера Вучо и Велимир Бата Живојиновић. „Скупљачи перја“ се сматра за један од најзначајнијих филмова црног таласа и југословенске кинематографије уопште.'),
(18, 'Три ', 1967, 80, '„Три“ је је једно од најбољих остварења црног таласа у југословенском филму. Филм је снимљен 1965. године, а режирао га је Александар Петровић, који је писао и сценарио по мотивима збирке приповедака „Папрат и ватра“Антонија Исаковића. Припада остварењима црног таласа.'),
(19, 'Црвено класје', 1970, 85, 'Бивши партизан, а после рата омладински активиста, одлази у једно село у Штајерској да од сељака откупи летину и убеди их да уђу у задругу. После привидних успеха и стварних неуспеха, он испуњава партијски задатак. Задруга је основана, али њен настанак није резултат убеђивања, него претњи и уцена. Растрзан тим сазнањем, а интимно несрећан због пораза у љубави, он у тренутку остварења своје друштвене мисије, убија недужног човека.');

--
-- Triggers `filmovi`
--
DROP TRIGGER IF EXISTS `brisiOtkaceneGlumce`;
DELIMITER //
CREATE TRIGGER `brisiOtkaceneGlumce` AFTER DELETE ON `filmovi`
 FOR EACH ROW begin 
delete from glumci
where gid not in (select gid from `mid-gid-uid`);
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `delFilm1`;
DELIMITER //
CREATE TRIGGER `delFilm1` BEFORE DELETE ON `filmovi`
 FOR EACH ROW begin
delete 
from uloge
where uloge.uid in (
select m.uid 
from `mid-gid-uid` m 
where old.mid=m.mid
);
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `glumac_uloga`
--
CREATE TABLE IF NOT EXISTS `glumac_uloga` (
`mid` int(5) unsigned
,`gID` int(4) unsigned
,`глумац` varchar(46)
,`uid` int(5) unsigned
,`улога` varchar(86)
);
-- --------------------------------------------------------

--
-- Table structure for table `glumci`
--

CREATE TABLE IF NOT EXISTS `glumci` (
  `gID` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `глумац` varchar(46) DEFAULT NULL,
  PRIMARY KEY (`gID`),
  UNIQUE KEY `gID` (`gID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=70 ;

--
-- Dumping data for table `glumci`
--

INSERT INTO `glumci` (`gID`, `глумац`) VALUES
(1, 'Александар Гаврић'),
(2, 'Ален Куни'),
(3, 'Ана Милосављевић'),
(4, 'Ангелца Хлебце'),
(5, 'Ани Жирардо'),
(6, 'Анка Зупанц'),
(7, 'Беким Фехмију'),
(8, 'Богдан Тирнанић'),
(9, 'Братољуб Глигоријевић'),
(10, 'Велимир Бата Живојиновић'),
(11, 'Вера Јовановић - Шеговић'),
(12, 'Вера Чукић'),
(13, 'Воја Мирић'),
(14, 'Вукица Ђилас'),
(15, 'Данило Бата Стојковић'),
(16, 'Драган Николић'),
(17, 'Драго Чумић'),
(18, 'Драгољуб Алексић'),
(19, 'Драгомир Бојанић Гидра'),
(20, 'Драгомир Фелба'),
(21, 'Душан Јанићијевић'),
(22, 'Душица Жегарац'),
(23, 'Ева Рас'),
(24, 'Желимира Жујовић'),
(25, 'Жика Миленковић'),
(26, 'Зоран Радмиловић'),
(27, 'Иван Палих'),
(28, 'Ивица Видовић'),
(29, 'Ирена Глонар'),
(30, 'Јагода Калопер'),
(31, 'Јелена Жигон'),
(32, 'Јелисавета Саблић'),
(33, 'Јован Јанићијевић Бурдуш'),
(34, 'Лепа Лукић'),
(35, 'Љуба Тадић'),
(36, 'Љубиша Ристић'),
(37, 'Љубиша Самарџић'),
(38, 'Мајда Грбац'),
(39, 'Мајда Потокар'),
(40, 'Марија Бакса'),
(41, 'Марко Николић'),
(42, 'Мија Алексић'),
(43, 'Милан Јелић'),
(44, 'Милена Дравић'),
(45, 'Миливоје Томић'),
(46, 'Миља Вујановић'),
(47, 'Мимси Фармер'),
(48, 'Миодраг Андрић'),
(49, 'Мирјана Блашковић'),
(50, 'Неда Арнерић'),
(51, 'Неда Спасојевић'),
(52, 'Никола Милић'),
(53, 'Оливера Вучо'),
(54, 'Павле Вуисић'),
(55, 'Петар Банићевић'),
(56, 'Раде Марковић'),
(57, 'Раде Шербеџија'),
(58, 'Ружица Сокић'),
(59, 'Северин Бијелић'),
(60, 'Сенка Велетанлић'),
(61, 'Слободан Алигрудић'),
(62, 'Слободан Перовић'),
(63, 'Ташко Начић'),
(64, 'Томислав Готовац'),
(65, 'Тули Купферберг'),
(66, 'Уго Тоњаци'),
(67, 'Фабијан Шоваговић'),
(68, 'Фарук Беголи'),
(69, 'Чедомир Радовић');

--
-- Triggers `glumci`
--
DROP TRIGGER IF EXISTS `brisiOtkaceneReditelje`;
DELIMITER //
CREATE TRIGGER `brisiOtkaceneReditelje` AFTER DELETE ON `glumci`
 FOR EACH ROW begin 
delete from reditelji
where rid not in (select rid from `mid-rid`);
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `ids`
--
CREATE TABLE IF NOT EXISTS `ids` (
`mid` int(5) unsigned
,`rid` int(5) unsigned
,`sid` int(5) unsigned
,`zid` int(5) unsigned
);
-- --------------------------------------------------------

--
-- Table structure for table `mid-gid-uid`
--

CREATE TABLE IF NOT EXISTS `mid-gid-uid` (
  `mID` int(5) unsigned NOT NULL,
  `gID` int(5) unsigned NOT NULL,
  `uID` int(5) unsigned NOT NULL,
  KEY `mid_fkgu_idx` (`mID`),
  KEY `gid_fk_idx` (`gID`),
  KEY `uid_fk_idx` (`uID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `mid-gid-uid`
--

INSERT INTO `mid-gid-uid` (`mID`, `gID`, `uID`) VALUES
(18, 10, 1),
(18, 62, 2),
(18, 60, 3),
(18, 13, 4),
(17, 7, 5),
(17, 53, 6),
(17, 10, 7),
(2, 62, 8),
(2, 22, 9),
(2, 59, 10),
(2, 49, 11),
(2, 52, 12),
(2, 45, 13),
(2, 54, 14),
(2, 43, 15),
(7, 16, 16),
(7, 61, 17),
(7, 48, 18),
(7, 59, 19),
(15, 33, 20),
(15, 6, 21),
(15, 21, 22),
(15, 10, 23),
(8, 23, 24),
(8, 61, 25),
(8, 48, 26),
(8, 58, 27),
(6, 37, 28),
(6, 50, 29),
(6, 44, 30),
(6, 42, 31),
(6, 35, 32),
(6, 51, 33),
(6, 31, 34),
(6, 68, 35),
(1, 5, 36),
(1, 27, 37),
(1, 42, 38),
(1, 23, 39),
(1, 19, 40),
(1, 10, 41),
(1, 55, 42),
(12, 18, 43),
(12, 9, 44),
(12, 11, 45),
(12, 3, 46),
(4, 44, 47),
(4, 28, 48),
(4, 59, 49),
(4, 61, 50),
(4, 54, 51),
(4, 20, 52),
(16, 46, 53),
(16, 8, 54),
(16, 69, 55),
(16, 41, 56),
(16, 61, 57),
(16, 24, 58),
(3, 62, 59),
(3, 43, 60),
(3, 32, 61),
(19, 57, 62),
(19, 29, 63),
(19, 38, 64),
(19, 39, 65),
(19, 4, 66),
(10, 44, 67),
(10, 28, 68),
(10, 30, 69),
(10, 65, 70),
(10, 26, 71),
(13, 64, 72),
(13, 14, 73),
(13, 36, 74),
(11, 16, 75),
(11, 40, 76),
(11, 1, 77),
(11, 15, 78),
(9, 66, 79),
(9, 2, 80),
(9, 47, 81),
(9, 10, 82),
(9, 54, 83),
(9, 67, 84),
(9, 35, 85),
(9, 63, 86),
(9, 15, 87),
(5, 12, 88),
(5, 10, 89),
(5, 25, 90),
(5, 54, 91),
(5, 34, 92),
(5, 61, 93),
(14, 37, 94),
(14, 50, 95),
(14, 68, 96),
(14, 22, 97),
(14, 42, 98),
(14, 35, 99),
(14, 17, 100),
(14, 56, 101);

-- --------------------------------------------------------

--
-- Table structure for table `mid-rid`
--

CREATE TABLE IF NOT EXISTS `mid-rid` (
  `mID` int(5) unsigned NOT NULL,
  `rID` int(5) unsigned NOT NULL,
  KEY `mid_idx` (`mID`),
  KEY `rid_fk_idx` (`rID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Veza izmedju tabele filmovi i tabele reditelj';

--
-- Dumping data for table `mid-rid`
--

INSERT INTO `mid-rid` (`mID`, `rID`) VALUES
(18, 1),
(17, 1),
(1, 1),
(9, 1),
(3, 2),
(8, 3),
(12, 3),
(10, 3),
(15, 4),
(16, 5),
(2, 6),
(7, 6),
(4, 6),
(19, 6),
(5, 7),
(11, 8),
(13, 9),
(3, 10),
(6, 11),
(14, 11);

-- --------------------------------------------------------

--
-- Table structure for table `mid-sid`
--

CREATE TABLE IF NOT EXISTS `mid-sid` (
  `mID` int(5) unsigned NOT NULL,
  `sID` int(5) unsigned NOT NULL,
  KEY `mid_fks_idx` (`mID`),
  KEY `sid_fk_idx` (`sID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Veza izmedju tabele filmovi i tabele scenario';

--
-- Dumping data for table `mid-sid`
--

INSERT INTO `mid-sid` (`mID`, `sID`) VALUES
(15, 1),
(18, 2),
(17, 2),
(1, 2),
(9, 2),
(5, 3),
(16, 4),
(2, 5),
(7, 5),
(3, 5),
(5, 5),
(2, 6),
(8, 7),
(12, 7),
(10, 7),
(15, 8),
(16, 9),
(4, 10),
(19, 10),
(11, 11),
(13, 12),
(2, 13),
(7, 13),
(3, 13),
(6, 14),
(14, 14);

-- --------------------------------------------------------

--
-- Table structure for table `mid-zid`
--

CREATE TABLE IF NOT EXISTS `mid-zid` (
  `mID` int(5) unsigned NOT NULL,
  `zID` int(5) unsigned NOT NULL,
  KEY `mid_fkz_idx` (`mID`),
  KEY `zid_fk_idx` (`zID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Veza izmedju tabele filmovi i tabele zanr';

--
-- Dumping data for table `mid-zid`
--

INSERT INTO `mid-zid` (`mID`, `zID`) VALUES
(12, 1),
(16, 1),
(10, 1),
(13, 1),
(17, 2),
(2, 2),
(7, 2),
(8, 2),
(1, 2),
(4, 2),
(16, 2),
(3, 2),
(19, 2),
(10, 2),
(13, 2),
(11, 2),
(9, 2),
(5, 2),
(14, 2),
(10, 3),
(18, 4),
(15, 4),
(6, 4),
(9, 5),
(5, 5),
(9, 6);

-- --------------------------------------------------------

--
-- Table structure for table `reditelji`
--

CREATE TABLE IF NOT EXISTS `reditelji` (
  `rID` int(3) unsigned NOT NULL AUTO_INCREMENT,
  `редитељ` varchar(46) DEFAULT NULL,
  PRIMARY KEY (`rID`),
  UNIQUE KEY `rid_in` (`rID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Tabela sa imenima reditelja' AUTO_INCREMENT=12 ;

--
-- Dumping data for table `reditelji`
--

INSERT INTO `reditelji` (`rID`, `редитељ`) VALUES
(1, 'Александар Петровић'),
(2, 'Гордан Михић'),
(3, 'Душан Макавејев'),
(4, 'Ђорђе Кадијевић'),
(5, 'Желимир Жилник'),
(6, 'Живојин Павловић'),
(7, 'Јован Живановић'),
(8, 'Јован Јовановић'),
(9, 'Лазар Стојановић'),
(10, 'Љубиша Козомара'),
(11, 'Пуриша Ђорђевић');

--
-- Triggers `reditelji`
--
DROP TRIGGER IF EXISTS `brisiOtkaceneScenariste`;
DELIMITER //
CREATE TRIGGER `brisiOtkaceneScenariste` AFTER DELETE ON `reditelji`
 FOR EACH ROW begin 
delete from scenaristi
where sid not in (select sid from `mid-sid`);
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `scenaristi`
--

CREATE TABLE IF NOT EXISTS `scenaristi` (
  `sID` int(3) unsigned NOT NULL AUTO_INCREMENT,
  `сценарио` varchar(46) DEFAULT NULL,
  PRIMARY KEY (`sID`),
  UNIQUE KEY `sID` (`sID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=15 ;

--
-- Dumping data for table `scenaristi`
--

INSERT INTO `scenaristi` (`sID`, `сценарио`) VALUES
(1, 'Александар Петковић'),
(2, 'Александар Петровић'),
(3, 'Богдан Јовановић '),
(4, 'Бранко Вучићевић'),
(5, 'Гордан Михић'),
(6, 'Драгољуб Ивков'),
(7, 'Душан Макавејев'),
(8, 'Ђорђе Кадијевић'),
(9, 'Желимир Жилник'),
(10, 'Живојин Павловић'),
(11, 'Јован Јовановић'),
(12, 'Лазар Стојановић'),
(13, 'Љубиша Козомара '),
(14, 'Пуриша Ђорђевић');

-- --------------------------------------------------------

--
-- Stand-in structure for view `sve`
--
CREATE TABLE IF NOT EXISTS `sve` (
`наслов` varchar(255)
,`редитељ` varchar(46)
,`сценарио` varchar(46)
,`година` year(4)
,`трајање` int(3) unsigned
,`жанр` varchar(24)
,`глумац` varchar(46)
,`улога` varchar(86)
,`коментар` text
);
-- --------------------------------------------------------

--
-- Table structure for table `uloge`
--

CREATE TABLE IF NOT EXISTS `uloge` (
  `uID` int(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Tabela uloga',
  `улога` varchar(86) DEFAULT NULL,
  PRIMARY KEY (`uID`),
  UNIQUE KEY `uID` (`uID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=102 ;

--
-- Dumping data for table `uloge`
--

INSERT INTO `uloge` (`uID`, `улога`) VALUES
(1, 'Милош Бојанић'),
(2, 'Невино оптужени'),
(3, 'Девојка'),
(4, 'Партизан'),
(5, 'Бели Бора Перјар'),
(6, 'Ленче'),
(7, 'Мирта'),
(8, 'Велимир Бамберг'),
(9, 'Фатална комшиница'),
(10, 'Фотограф Лале'),
(11, 'Курва'),
(12, 'Конобар'),
(13, 'Милорад'),
(14, 'Крманош'),
(15, 'Студент'),
(16, 'Џими Барка'),
(17, 'управник Милутин'),
(18, 'Ибро'),
(19, 'официр'),
(20, 'наредник Катић'),
(21, 'Синђелија'),
(22, 'Манола'),
(23, 'Недићев мајор'),
(24, 'Изабела'),
(25, 'Ахмед'),
(26, 'Мића'),
(27, 'Ружа'),
(28, 'Мали'),
(29, 'девојка'),
(30, 'Слободанка'),
(31, 'капетан Страја'),
(32, 'генерал Милан Прекић'),
(33, 'Марклена'),
(34, 'Ружа'),
(35, 'Рус Мишка'),
(36, 'Реза'),
(37, 'Триша'),
(38, 'Јошка'),
(39, 'Гоца'),
(40, 'пилот'),
(41, 'Милиционер - Исповедник'),
(42, 'Јошкин пријатељ'),
(43, 'Драгољуб Алексић, акробата (режија, продукција)'),
(44, 'господин Петровић'),
(45, 'игра одвратну маћеху'),
(46, 'тужна сирота Нада, сироче'),
(47, 'Милица'),
(48, 'Иве'),
(49, 'Зека'),
(50, 'Јотић'),
(51, 'старјешина села'),
(52, 'Тополовачки'),
(53, 'Југослава'),
(54, NULL),
(55, NULL),
(56, NULL),
(57, NULL),
(58, NULL),
(59, 'Ђука'),
(60, 'Тредиш'),
(61, 'Оља'),
(62, 'Јужек Хедл'),
(63, 'Туника'),
(64, 'Хана'),
(65, 'Зефа'),
(66, 'Лиза'),
(67, 'Милена'),
(68, 'Владимир Илић'),
(69, 'Јагода'),
(70, NULL),
(71, NULL),
(72, 'Том'),
(73, NULL),
(74, NULL),
(75, NULL),
(76, NULL),
(77, NULL),
(78, NULL),
(79, 'Николај Афанасијевић Максудов „Маестро“'),
(80, 'Професор Воланд, Сатана'),
(81, 'Маргарета Николајевна'),
(82, 'Коровјев, Сатанин слуга'),
(83, 'Азазело, Сатанин слуга'),
(84, 'Берлиоз, књижевник'),
(85, 'Понтије Пилат'),
(86, 'Римски, управник позоришта'),
(87, 'Бобов'),
(88, 'Бела Сека'),
(89, 'Ратомир Јованић Ратко'),
(90, 'Дамњан Илић Нуклеар'),
(91, 'Ратков стриц'),
(92, 'Луна'),
(93, 'директор хотела'),
(94, 'Љубиша'),
(95, 'Неда'),
(96, 'Рус Мишка'),
(97, 'Тања'),
(98, 'Страја'),
(99, 'Љуба'),
(100, 'обавештајац Чума'),
(101, 'Љубиша');

-- --------------------------------------------------------

--
-- Table structure for table `zanr`
--

CREATE TABLE IF NOT EXISTS `zanr` (
  `zID` int(2) unsigned NOT NULL AUTO_INCREMENT,
  `жанр` varchar(24) DEFAULT NULL,
  PRIMARY KEY (`zID`),
  UNIQUE KEY `zID` (`zID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;

--
-- Dumping data for table `zanr`
--

INSERT INTO `zanr` (`zID`, `жанр`) VALUES
(1, 'документарни'),
(2, 'драма'),
(3, 'комедија'),
(4, 'ратни'),
(5, 'Романтика'),
(6, 'Фантазија');

-- --------------------------------------------------------

--
-- Structure for view `безглумаца`
--
DROP TABLE IF EXISTS `безглумаца`;

CREATE ALGORITHM=UNDEFINED DEFINER=`umbra`@`%` SQL SECURITY DEFINER VIEW `безглумаца` AS select `f`.`наслов` AS `наслов`,`r`.`редитељ` AS `редитељ`,`s`.`сценарио` AS `сценарио`,`f`.`година` AS `година`,`f`.`трајање` AS `трајање`,`z`.`жанр` AS `жанр`,`f`.`коментар` AS `коментар` from ((((`filmovi` `f` join `reditelji` `r`) join `scenaristi` `s`) join `zanr` `z`) join `ids` `i`) where ((`i`.`mid` = `f`.`mID`) and (`i`.`rid` = `r`.`rID`) and (`i`.`sid` = `s`.`sID`) and (`i`.`zid` = `z`.`zID`));

-- --------------------------------------------------------

--
-- Structure for view `broj_uloga`
--
DROP TABLE IF EXISTS `broj_uloga`;

CREATE ALGORITHM=UNDEFINED DEFINER=`umbra`@`%` SQL SECURITY DEFINER VIEW `broj_uloga` AS select `g`.`глумац` AS `глумац`,count(`g`.`gID`) AS `број_улога`,min(`f`.`година`) AS `Од`,max(`f`.`година`) AS `До` from ((`glumci` `g` join `mid-gid-uid` `mug`) join `filmovi` `f`) where ((`g`.`gID` = `mug`.`gID`) and (`mug`.`mID` = `f`.`mID`)) group by `g`.`глумац` order by count(`g`.`gID`) desc;

-- --------------------------------------------------------

--
-- Structure for view `glumac_uloga`
--
DROP TABLE IF EXISTS `glumac_uloga`;

CREATE ALGORITHM=UNDEFINED DEFINER=`umbra`@`%` SQL SECURITY DEFINER VIEW `glumac_uloga` AS select `mgu`.`mID` AS `mid`,`g`.`gID` AS `gID`,`g`.`глумац` AS `глумац`,`u`.`uID` AS `uid`,`u`.`улога` AS `улога` from ((`glumci` `g` join `mid-gid-uid` `mgu`) join `uloge` `u`) where ((`g`.`gID` = `mgu`.`gID`) and (`mgu`.`uID` = `u`.`uID`));

-- --------------------------------------------------------

--
-- Structure for view `ids`
--
DROP TABLE IF EXISTS `ids`;

CREATE ALGORITHM=UNDEFINED DEFINER=`umbra`@`%` SQL SECURITY DEFINER VIEW `ids` AS select distinct `mid-rid`.`mID` AS `mid`,`mid-rid`.`rID` AS `rid`,`mid-sid`.`sID` AS `sid`,`mid-zid`.`zID` AS `zid` from (((`mid-rid` join `mid-sid` on((`mid-rid`.`mID` = `mid-sid`.`mID`))) join `mid-zid` on((`mid-rid`.`mID` = `mid-zid`.`mID`))) join `mid-gid-uid` on((`mid-rid`.`mID` = `mid-gid-uid`.`mID`)));

-- --------------------------------------------------------

--
-- Structure for view `sve`
--
DROP TABLE IF EXISTS `sve`;

CREATE ALGORITHM=UNDEFINED DEFINER=`umbra`@`%` SQL SECURITY DEFINER VIEW `sve` AS select `f`.`наслов` AS `наслов`,`r`.`редитељ` AS `редитељ`,`s`.`сценарио` AS `сценарио`,`f`.`година` AS `година`,`f`.`трајање` AS `трајање`,`z`.`жанр` AS `жанр`,`g`.`глумац` AS `глумац`,`u`.`улога` AS `улога`,`f`.`коментар` AS `коментар` from (((((((`filmovi` `f` join `reditelji` `r`) join `scenaristi` `s`) join `zanr` `z`) join `ids` `i`) join `mid-gid-uid` `mgu`) join `glumci` `g`) join `uloge` `u`) where ((`f`.`mID` = `i`.`mid`) and (`i`.`rid` = `r`.`rID`) and (`i`.`sid` = `s`.`sID`) and (`i`.`zid` = `z`.`zID`) and (`i`.`mid` = `mgu`.`mID`) and (`mgu`.`gID` = `g`.`gID`) and (`mgu`.`uID` = `u`.`uID`));

--
-- Constraints for dumped tables
--

--
-- Constraints for table `mid-gid-uid`
--
ALTER TABLE `mid-gid-uid`
  ADD CONSTRAINT `gid_fk` FOREIGN KEY (`gID`) REFERENCES `glumci` (`gID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `mid_fkgu` FOREIGN KEY (`mID`) REFERENCES `filmovi` (`mID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `uid_fk` FOREIGN KEY (`uID`) REFERENCES `uloge` (`uID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `mid-rid`
--
ALTER TABLE `mid-rid`
  ADD CONSTRAINT `mid_fk` FOREIGN KEY (`mID`) REFERENCES `filmovi` (`mID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `rid_fk` FOREIGN KEY (`rID`) REFERENCES `reditelji` (`rID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `mid-sid`
--
ALTER TABLE `mid-sid`
  ADD CONSTRAINT `mid_fks` FOREIGN KEY (`mID`) REFERENCES `filmovi` (`mID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sid_fk` FOREIGN KEY (`sID`) REFERENCES `scenaristi` (`sID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `mid-zid`
--
ALTER TABLE `mid-zid`
  ADD CONSTRAINT `mid_fkz` FOREIGN KEY (`mID`) REFERENCES `filmovi` (`mID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `zid_fk` FOREIGN KEY (`zID`) REFERENCES `zanr` (`zID`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
