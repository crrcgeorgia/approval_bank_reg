clear
set more off

use "http://caucasusbarometer.org/downloads/NDI_2019_July_04.08.19_Public.dta" 


recode SETTYPE - HHASIZE (-7=.) (-3=.) (-9=.)
 
 
 
/// weights
svyset PSU [pweight=WTIND], strata(SUBSTRATUM) fpc(NPSUSS)singleunit(certainty) || ID, fpc(NHHPSU) || _n, fpc(NADHH)


// /// recodes
recode RESPEDU (1=1) (2=1) (3=1) (4=2) (5=3) (6=3) , gen(RESPEDUrec)

label define RESPEDUrec 1 "Secondary or lower", modify
label define RESPEDUrec 2 "Vocational/technical degree", modify
label define RESPEDUrec 3 "Higher than secondary", modify

label values RESPEDUrec RESPEDUrec


/// Wealth index

foreach var of varlist  OWNFRDG OWNCOTV OWNSPHN OWNTBLT OWNCARS OWNAIRC OWNWASH OWNCOMP OWNHWT OWNCHTG {
recode `var' (-9/-1=0)
}

gen OWN = OWNFRDG + OWNCOTV + OWNSPHN + OWNTBLT + OWNCARS + OWNAIRC + OWNWASH + OWNCOMP + OWNHWT + OWNCHTG 

label values OWN OWN

// NewSettype

recode SUBSTRATUM (10=1) (21/26=2) (31/34=2) (51=2) (61=2)  (41/44=3) (52=3) (62=3) , gen(NEW_SETTYPE)
label var NEW_SETTYPE "Settlement type"

label define NEW_SETTYPE 1 "Capital", modify
label define NEW_SETTYPE 2 "Other urban", modify
label define NEW_SETTYPE 3 "Rural", modify

label value NEW_SETTYPE NEW_SETTYPE



// Party Support

recode PARTYSUPP1 (26=3) (9=.) (18=.) (20=.) (24=.) (-2=.) (1=4) (2=4) (4=4) (5=4) (11=4) (12=4) (14=4) (19=4) (21=4) (22=4) (3=3) (7=3) (10=3) (13=3) (15=3) (16=3) (17=3) (23=3) (6=2) (8=1) (25=5) (-1=5)

label define PARTYSUPP1 4 "Other parties", modify
label define PARTYSUPP1 3 "Liberal parties", modify
label define PARTYSUPP1 2 "UNM", modify
label define PARTYSUPP1 1 "GD", modify
label define PARTYSUPP1 5 "No party", modify

label values PARTYSUPP1 PARTYSUPP1


// logit reg
recode HAVLOAN HAVEJOB RESPEDUrec NOMNUTL OWN EMPLGOVP  (-1=.) (-2=.)

recode APPLNREG (1=1) (-1=0) (-2=0) (0=0)

label define APPLNREG 1 "Approve", modify
label define APPLNREG 0 "Everything else", modify

label values APPLNREG APPLNREG



logit APPLNREG i.HAVLOAN i.AGEGROUP i.NEW_SETTYPE  i.RESPEDUrec c.OWN i.PARTYSUPP1  i.HAVEJOB

svy: logistic APPLNREG i.HAVLOAN i.AGEGROUP i.NEW_SETTYPE  i.RESPEDUrec c.OWN i.PARTYSUPP1  i.HAVEJOB
margins, dydx(*) atmeans post
marginsplot


qui svy: logistic APPLNREG i.HAVLOAN i.AGEGROUP i.NEW_SETTYPE i.RESPEDUrec c.OWN i.PARTYSUPP1  i.HAVEJOB
margins, at(HAVLOAN=(0 1))
marginsplot

margins, at(AGEGROUP=(1 2 3))
marginsplot

margins, at(NEW_SETTYPE=(1 2 3))
marginsplot

margins, at(RESPEDUrec=(1 2 3))
marginsplot

margins, at(HAVEJOB=(0 1))
marginsplot

margins, at(PARTYSUPP1=(1 2 3 4 5))
marginsplot


qui svy: logit APPLNREG b02.HAVLOAN i.AGEGROUP i.NEW_SETTYPE i.RESPEDUrec c.OWN i.PARTYSUPP1  i.HAVEJOB
estat gof, all




