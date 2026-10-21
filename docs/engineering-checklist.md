# Golden Checklist (copy into your project, tick there)

Har item ke saath source likha hai (id = `CATALOG.md` mein). Items sirf wo hain jo in documents mein khud likhe hain. "Proof" ka matlab: test, script ya naap, sirf "maine dekha" nahi.
Status: [ ] baaki  [x] ho gaya (proof ke saath)  [-] is project ke liye laagu nahi (kaaran likho)

## A. AI se code likhwate waqt
- [ ] AI ne jo code likha use wahi review aur testing se guzaro jo insaan ke code ko guzarte hain. Insecure code aam hai: Pearce 2021 (A03), Perry 2023 (A04: AI assistant wale participants ne 5 mein se 4 tasks mein zyada insecure code likha, aur apne code ko secure maanne ki sambhavna bhi zyada thi).
- [ ] AI ke suggest kiye har naye package/library ko registry mein khud check karo. AI naam gadh leta hai: Spracklen 2024 (A05).
- [ ] Tests mazboot rakho. Kamzor tests par AI ka galat code bhi pass ho jaata hai: EvalPlus (A10).
- [ ] Context chhota aur saaf rakho. Lambe context mein beech ki baatein bhool jaati hain: Lost in the Middle (A08), Anthropic context engineering (A15).
- [ ] AI se kaam chhote, jaanche hue tukdon mein karwao; agent ko saaf tools aur saaf kaam do: SWE-agent (A07), Anthropic agents (A14, A16).
- [ ] "Fast hua" maanne se pehle naapo. Experienced open-source developers par randomized trial mein AI se kaam 19% zyada samay mein hua (METR, A02), jabki ek alag Copilot experiment mein ek task 55% tezi se hua (Peng, A01). Dono ke hisaab alag the, isliye apne project mein khud naapo.
- [ ] AI se bani files ko design ke hisaab se rakho (raaz chhupana, boundary), sirf chhoti files ke liye nahi bantna: 10-ai-agents-and-code (2025 modular imperative, 2026 AI smells).
- [ ] AI adoption ka delivery throughput aur stability par asar naapo (sirf speed nahi): DORA 2024 Figure 10 (H02).

## B. Code organisation aur modularity
- [ ] Har module ek aisa faisla chhupata hai jo kal badal sakta hai (kaam ke steps se nahi todna): Parnas 1972 (01).
- [ ] Andar ka business niyam bahar ki cheezon (screen, database, server) par nirbhar nahi; bahar adapter: Hexagonal (08), Clean Architecture (08).
- [ ] Koi circular dependency nahi (sabse aam architecture smell): 02-architecture-debt (Li 2021).
- [ ] Jo badlaav boundary paar karte hain unhe naapo; wahi sabse zyada bug laate hain: Kouroshfar 2015 (02).
- [ ] Boundary ek tool se lagu ho, sirf niyam likhne se nahi: Shopify Packwerk (07), project ka architecture test.
- [ ] Business ke dabbe (bounded context) saaf: Evans DDD Reference (J01), Fowler (J02).
- [ ] File ki size ko thermometer maano, bimaari nahi; ghatao sirf tab jab andar ka rishta bhi badle: El Emam 1999, Chowdhury 2022 (03).
- [ ] State kam rakho; complexity ka bada kaaran wahi hai: Out of the Tar Pit (B15).
- [ ] Dependency injection se test aur badlaav aasaan: Fowler DI (08), Sun & Kim 2022 (08).
- [ ] Ek jaisi cheez ke liye ek hi raasta (duplicate code nahi): Foote & Yoder Big Ball of Mud (01).

## C. Efficiency aur optimization
- [ ] Pehle naapo, phir optimize karo ("premature optimization" ka pura sandarbh): Knuth 1974 (D04).
- [ ] Bottleneck dhundne ka tareeka: Utilization, Saturation, Errors: Gregg USE (D03).
- [ ] Scale se pehle dekho ki ek achhe single-thread se bhi kam to nahi: McSherry COST (D01).
- [ ] Benchmark jhooth bol sakte hain; setup randomize karo: Mytkowicz 2009 (naam list mein, paywall ki wajah se file nahi).
- [ ] Memory/cache ka behaviour samjho: Drepper (D02).
- [ ] Slow requests (tail) hi user ka anubhav tay karti hain: Tail at Scale (C08).
- [ ] Database mein sahi index; query plan dekho: Use the Index Luke (E07), Postgres docs (E08).
- [ ] Cache ka design soch kar (invalidation, thundering herd): Scaling Memcache (E02), TAO (E01).

## D. Reliability aur operations
- [ ] Service level targets (SLO) likhe hue, error budget ke saath: SRE Book (C02, C01).
- [ ] Overload mein kaam kam karo (load shedding), sab ko girne mat do: AWS (C15), SRE Handling Overload (C06).
- [ ] Retry timeout aur jitter ke saath, warna retry toofan ban jaata hai: AWS (C14).
- [ ] Cascading failure ke liye soch aur test: SRE (C04), Metastable failures (C09, C10).
- [ ] Error handling bugs hi zyada bade outage laate hain; unhe test karo: Yuan 2014 (C12).
- [ ] Monitoring: logs, metrics, alerts sirf wahi jo kisi ko jagane layak ho: SRE (C03). Tracing: Dapper (C11).
- [ ] Har bade outage ke baad blameless postmortem: SRE (C05); aur yaad rakho ki kai chhote kaaran milkar toot-te hain: Cook (C07).
- [ ] Config environment se, app deploy-yogya: 12-factor (C13).
- [ ] Payment/important kaam idempotent, taaki retry safe ho: Stripe (F05).

## E. Data aur distributed systems
- [ ] Jaano ki tum CAP ke kis side par ho, aur uska matlab kya hai: Gilbert & Lynch (B10), Kleppmann (B11).
- [ ] Transaction isolation level jaan-boojh kar chuna: Berenson 1995 (E05), Postgres MVCC (E09).
- [ ] Distributed transaction se bacho; idempotent kaam aur entity-wise boundary: Helland 2007 (B13).
- [ ] Consensus khud mat banao; Raft jaise proven kaam ko samjho aur istemal karo: Raft (B03).
- [ ] Jaanch end par ho (end-to-end), beech ke layer par nahi: Saltzer 1984 (B12).
- [ ] Ek database sab ke liye nahi: Stonebraker (E04).

## F. API
- [ ] Resource-based, naming aur errors ek jaise: Google API Guide (F01, F02), Microsoft guide (F04).
- [ ] Purane clients ko tode bina badlaav (compatibility) aur deprecation ka tareeka: SWE at Google ch.15 (H09).
- [ ] Safe retries ke liye idempotency key: Stripe (F05).

## G. Security
- [ ] OWASP Top 10 ke saare risks par jawab likha hua: G01. Mobile app: MASVS (G03). Detail checklist: ASVS (G02).
- [ ] Secure development practices NIST SSDF ke hisaab se: G04.
- [ ] Least privilege aur baaki design principles: Saltzer & Schroeder (G06), Google (09 ch.5).
- [ ] Supply chain: kya build hua, kisne banaya (SLSA, Binary Authorization): G05, 09.
- [ ] Code samajhne yogya rakho (understandability) aur system resilient: Google SRS ch.6 (G08), ch.8 (G09).
- [ ] Jis code ko tum ne khud build nahi kiya use poora bharose ka mat maano: Thompson (G07).

## H. Delivery aur team process
- [ ] Chhote code review, jaldi review: Google (05), SWE at Google ch.9 (H04).
- [ ] CI har badlaav par; CD chhote, baar-baar: SWE at Google ch.23, 24 (H07, H08); DORA (H01, H02).
- [ ] Trunk-based, chhoti branches: H10, SWE at Google ch.16 (H05).
- [ ] Build reproducible aur tez: Build Systems a la Carte (06), SWE at Google ch.18 (H06).
- [ ] Static analysis CI mein, jisme galat-positive kam ho: Tricorder (06), Sadowski 2018 (06).
- [ ] Testing pyramid (zyada chhote tests, kam bade): H11, Google testing chapters (04).
- [ ] Flaky tests ko seedha theek karo ya hatao: Luo 2014, Parry 2022 (04).
- [ ] Purana code hatana bhi plan ka hissa: H09.

## I. Cloud/infra review (kab sab kuch ek saath dekhna ho)
- [ ] AWS six pillars: I01. Azure: I02. Google Cloud: I03. Har pillar par ek line mein jawab: reliability, security, cost, performance, operations, sustainability (jo laagu ho).

## J. Naya project shuru karte waqt
- [ ] `AGENT-INSTRUCTIONS.md` padhi; project ke andar `docs/research/` folder banaya.
- [ ] Is checklist ki copy project mein hai aur har item ke saamne proof link hai.
- [ ] Project ke apne papers/guides (apni framework, database, payment provider) alag se jode.
