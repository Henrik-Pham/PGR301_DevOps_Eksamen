Oppgave 1A 

https://9vxs7kd0ua.execute-api.eu-west-1.amazonaws.com/Prod/generate-image

Oppgave 1B

https://github.com/Henrik-Pham/PGR301_DevOps_Eksamen/actions/runs/11805125491/job/32886886320

Oppgave 2B

Main branch:
https://github.com/Henrik-Pham/PGR301_DevOps_Eksamen/actions/runs/11824548621/job/32946296092
Feature branch:
https://github.com/Henrik-Pham/PGR301_DevOps_Eksamen/actions/runs/11825430445/job/32949170969
SQS-kø URL:
https://sqs.eu-west-1.amazonaws.com/244530008913/ka37_image_generation_queue

Github actions med oppgave 4:

https://github.com/Henrik-Pham/PGR301_DevOps_Eksamen/actions/runs/11879787037/job/33102132601

Oppgave 3
Beskrivelse av taggestrategi:

Jeg bruker en enkel taggestrategi der docker imaget tagges kun med “latest”, som vil si at hver gang det pushes endringer til main, oppdateres imaget til det nyeste versjonen. Denne strategien er valgt for å ha den nyeste versjonen tilgjengelig uten å skape flere tags for hver commit. Dette er essensielt i utviklingsmiljøer hvor det er viktig å ha den nyeste og stabile versjonen tilgjengelig enn å kunne gå tilbake til spesifikke commit eller versjons-baserte bilder.

Container image:

henrikdevops729/image-generator

SQS URL: 

https://sqs.eu-west-1.amazonaws.com/244530008913/ka37_image_generation_queue

Oppgave 4

Løst med oppgave 2

Oppgave 5

Automatisering og kontinuerlig levering (CI/CD)
CI/CD-prosesser i en serverless arkitektur er mer delt opp, og hver funksjon fungerer som en uavhengig komponent. Hver Lambda-funksjon kan ha sin egen CI/CD-pipeline, og det gir fleksibilitet til å deploye individuelle funksjoner uavhengig andre deler av systemet. Dette kan for eksempel være en funksjon som håndterer ulike meldinger fra en SQS-kø, og deployes uten å påvirke en annen funksjon som håndterer bildeopplasting til S3. Risikoen for feil blir derfor lav, men det medfører også høyere kompleksitet, da flere pipelines må vedlikeholdes og synkroniseres.
Mikrotjenestearkitekturer er vanlig sammensatte, hvor hele tjenesten deployes som en enhet for eksempel gjennom en container i docker. Dette forenkler pipeline-strukturen, siden én pipeline kan håndtere hele mikrotjenesten. Ulempen med dette er at om man skal deploye små endringer så kreves det full utrulling, og dette kan øke sjansen for error.

Observability (overvåkning)
Observability i serverless-arkitekturer er utfordrende på grunn av mange små oppdelte komponenter Feilsøking krever ofte å backtrace mellom loggfiler fra flere Lambda-funksjoner, og andre tjenester. Hvis en melding blir forsinket i en SQS-kø, kan det være vanskelig å spore om problemet ligger i meldingsproduksjonen, køen, eller funksjonen som tar opp køen. Cloudwatch fra AWS kan gi forståelse for problemet, men det krever at teamet implementerer gode løsninger som gjør det enkelt å spore tvers komponenter, og i en serverless arkitektur får man bedre helheltig forståelse for hver enkelt funksjon, men det blir utfordrende å få en fullstending oversikt over hele systemet for man trenger ofte avanserte verktøy for å spore prosesser tvers av tjenester.
Mikrotjenester gir et mer samlet oppsett for logging og overvåkning, men krever ofte mer avanserte verktøy for å spore komplekse prosesser som går på tvers av flere tjenester.
Skalerbarhet og kostnadskontroll
AWS Lambda skalerer automatisk med antall forespørsler, og man betaler kun for antall requests for lambda funksjonen og hvor lang tid det tar for å kjøre funksjonen. Dette gjør det til en solid løsning for uforutsigbare arbeidsmengder. For eksempel kan et system som håndterer en økning i trafikk under kampanjer som Black Friday raskt skalere uten at DevOps-teamet trenger å justere infrastrukturen manuelt. Kostnadsmodellen gir også fordeler for arbeidsbelastninger med variabel bruk, men ved konstant høy belastning kan kostnadene eskalere sammenlignet med dedikerte mikrotjeneste-løsninger. Dette kan bli kostbart i tid og ressurser.


Eierskap og ansvar
For en serverless tilnærming overtar vi vårt ansvar for infrastrukturen til skyleverandøren som kan være AWS. Dette innebærer at skyleverandøren håndterer fremtidige oppdateringer, skalering og sikkerhet. DevOps-teamet får da mer tid til å fokusere på videre utvikling. For eksempel trenger teamet å ikke bekymre seg for å administrere servere eller operativsystemer. Samtidig kan teamet oppleve begrenset kontroll over infrastrukturen fordi vanskeligheter med ytelse eller latency kan være utfordringer å løse, da man ikke har direkte tilgang til plattformens drift, som betyr at problemer med ytelse kan være utfordrende å løse.
På den ene siden I mikrotjenestearkitekturer står DevOps teamet for ansvaret for infrastrukturen, som gir dem muligheter til å optimalisere ytelse og kostnader. På den andre siden må teamet håndtere alt fra oppdateringer, oppsett, skalering og feilhåndtering, noe som krever mye tid og god forståelse.










