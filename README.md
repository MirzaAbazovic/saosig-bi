BI projekat za Sarajevo-Osiguranje d.o.o

Svrha projekta je da obezbjedi poslovnim analiticarima analize podataka o policama i stetama.

Projekat je baziran na open source software-u
- 	DB server je MySql Community Server 5 (http://dev.mysql.com/downloads/mysql/)
-	Online Analytical Processing server (OLAP) je Mondrian (http://community.pentaho.com/projects/mondrian/)
-	Korisnicko sucelje je Saiku(http://www.meteorite.bi/saiku)

Ver 0.1
Analiza placenih steta u 2013 po tarifama i podruznicama. Hijearhija vremena sadrzi mjesec.
Napravljena je mondrain shema i podaci su prebaceni za placene stete u 2013

Planirano u ver 0.1.1
1.	Prebaciti podatke o isplatama za 2013 i jan,feb 2014
2.	Uvesti dimenziju Osiguranik sa hijerahijama, polica, naziv osiguranika -> organizacijska struktura ostecenika   
