import '../models/driver_factor.dart';
import '../models/risk_category.dart';

/// Actionable mitigation bullets keyed by exact factor labels for all categories.
abstract final class DriverMitigationSteps {
  /// Bullets to show for this driver.
  static List<String> stepsFor(DriverFactor driver) {
    switch (driver.category) {
      case RiskCategory.financial:
        final s = _financial[driver.label];
        assert(
          s != null,
          'Missing mitigation copy for financial factor: ${driver.label}',
        );
        return s!;
      case RiskCategory.digitalPrivacy:
        final s = _digital[driver.label];
        assert(
          s != null,
          'Missing mitigation copy for digital factor: ${driver.label}',
        );
        return s!;
      case RiskCategory.health:
        final s = _health[driver.label];
        assert(
          s != null,
          'Missing mitigation copy for health factor: ${driver.label}',
        );
        return s!;
      case RiskCategory.career:
        final s = _career[driver.label];
        assert(
          s != null,
          'Missing mitigation copy for career factor: ${driver.label}',
        );
        return s!;
      case RiskCategory.personalSafety:
        final s = _personalSafety[driver.label];
        assert(
          s != null,
          'Missing mitigation copy for personal safety factor: ${driver.label}',
        );
        return s!;
    }
  }

  static const Map<String, List<String>> _health = {
    'Chronic or acute conditions you manage': [
      'Keep a one-page health summary (diagnoses, meds, allergies, key providers) updated and accessible for emergencies.',
      'Book follow-ups on a calendar rhythm so flare-ups do not slide until they are urgent.',
      'Ask your clinician about the smallest lifestyle changes with evidence for your condition—pick one to try for 4–8 weeks.',
      'If costs block care, ask about generics, patient assistance programs, or payment plans before skipping treatment.',
    ],
    'Day-to-day pain, fatigue, or symptoms': [
      'Track sleep, activity, and symptom spikes for two weeks—patterns often reveal triggers you can adjust.',
      'Prioritize one recovery habit (consistent bedtime, gentle movement, hydration) rather than overhauling everything.',
      'Split demanding tasks across days; say no once where you usually push through pain or exhaustion.',
      'Discuss persistent symptoms with a clinician—unexplained worsening deserves a proper workup, not only coping.',
    ],
    'Sleep quality and energy most weeks': [
      'Fix wake time first; a stable morning anchor improves sleep pressure more than chasing perfect bedtimes.',
      'Dim screens and heavy meals in the last hour before bed; keep the bedroom cool, dark, and quiet.',
      'Limit late caffeine and alcohol; both fragment sleep even when they feel helpful in the moment.',
      'If insomnia lasts weeks, consider CBT-I or a sleep clinic—behavioral treatment often beats long-term sedatives.',
    ],
    'Preventive care and screenings you skip or delay': [
      'List overdue items (dental, vision, labs, vaccines) and schedule the easiest one this month.',
      'Use preventive benefits your plan already covers—many waive copays for defined screenings.',
      'Pair appointments with something rewarding afterward so the day feels less like pure chore.',
      'If fear or past bad experiences block you, tell staff upfront; many offices have accommodations or slower-paced visits.',
    ],
    'Wait times, referrals, or specialist access': [
      'Ask your PCP for a referral to a specific named specialist or group with shorter availability.',
      'Call weekly for cancellation lists; midday calls sometimes catch openings.',
      'For non-urgent issues, consider telehealth triage to confirm you need a specialist before waiting months.',
      'Document symptoms with dates so the first specialist visit is efficient and you are not sent back for more tests.',
    ],
    'Distance, cost, or logistics blocking care': [
      'Batch appointments on one day with childcare or ride help lined up in advance.',
      'Check FSA/HSA eligibility, community clinics, and sliding-scale centers for the services you need.',
      'Use mail-order pharmacy or 90-day fills when cheaper; compare cash prices with discount apps for generics.',
      'If work blocks daytime visits, ask for the earliest, latest, or telehealth slots explicitly.',
    ],
    'Sensitivity to a large medical bill': [
      'Build or name a dedicated medical buffer (even small) separate from everyday checking.',
      'Before non-emergency procedures, get an estimate in writing and ask about cash or bundled pricing.',
      'Review EOBs for duplicate charges or out-of-network surprises; appeal clear errors.',
      'If a bill is unpayable, negotiate a payment plan early—hospitals often prefer steady partial payments.',
    ],
    'Gaps in insurance vs. what you might need': [
      'List worst-case scenarios (ER, surgery, chronic Rx) and check deductibles, OOP max, and network for each.',
      'During open enrollment, compare total cost (premium + expected care), not premium alone.',
      'Consider supplemental or critical-illness coverage only after understanding exclusions and waiting periods.',
      'If between jobs, map COBRA, marketplace, or spouse coverage timelines so you do not sit uninsured.',
    ],
    'Prescription and ongoing treatment affordability': [
      'Ask about therapeutic equivalents, dose splitting where safe, or manufacturer coupons for brand drugs.',
      'Compare pharmacy prices; chains and independents often differ materially for the same Rx.',
      'Use automatic refills and mail order to avoid lapse fees or urgent retail markups.',
      'Discuss deprescribing or lower-cost alternatives with your clinician when a drug’s benefit is unclear.',
    ],
    'Stress, anxiety, or low mood impact on life': [
      'Name one small boundary (evening offline block, shorter meetings) that protects recovery time.',
      'Try brief daily practices with evidence (walks, breathing, journaling triggers) for 2–3 weeks before judging.',
      'If symptoms affect work or relationships for weeks, book counseling or psychiatry—waiting lists reward early signup.',
      'Tell one trusted person how you are really doing; isolation amplifies most mood problems.',
    ],
    'Habits that could affect health (sleep, substance, etc.)': [
      'Pick one habit to reduce (not five); measure it weekly so progress is visible.',
      'Replace triggers: swap the routine after the cue while keeping a similar reward (tea instead of late wine, etc.).',
      'Use professional help for substances if stopping alone has failed or withdrawal could be risky.',
      'Sleep, movement, and alcohol interact—fixing sleep often makes other habits easier to change.',
    ],
    'Social support when things get hard': [
      'Identify two people who could help practically (rides, childcare) vs. emotionally—ask clearly for one type.',
      'Join a condition-specific or caregiver group online or locally; shared experience reduces shame.',
      'Schedule low-stakes contact (walk, coffee) before crisis so relationships are warm when you need them.',
      'If family is part of the stress, consider mediated conversations or therapy focused on boundaries.',
    ],
    'Health needs of children or elders you support': [
      'Centralize calendars, meds, and provider contacts in one shared doc or app.',
      'Clarify legal and financial authority (POA, guardianship) before an emergency forces rushed decisions.',
      'Rotate respite with other family or paid help—even short breaks reduce burnout-driven mistakes.',
      'Review school IEP/504 or elder care plans yearly; needs change faster than paperwork.',
    ],
    'Caregiving time and burnout risk': [
      'Track hours weekly; if unpaid care rivals a job, treat it like one with planned time off.',
      'Delegate specific tasks (“you handle Tuesdays”) instead of vague “let me know if you need help.”',
      'Use adult day programs, visiting nurses, or meal services where eligible—partial help still moves the needle.',
      'Watch your own vitals, sleep, and mood; caregiver burnout often shows up as irritability and illness first.',
    ],
    'Coverage and planning for dependents’ care': [
      'Verify dependents are correctly enrolled and that custodial parents match insurer records.',
      'Save for deductibles in an HSA/FSA if available; tag the balance mentally for kids’ braces, therapy, or sports injuries.',
      'Document guardianship wishes and emergency contacts where schools and caregivers can find them.',
      'If elders rely on you, map Medicare parts, Medigap, and long-term care options before a hospital discharge rush.',
    ],
  };

  static const Map<String, List<String>> _career = {
    'Job or role security over the next year': [
      'Clarify performance expectations in writing; align visible wins with what leadership says matters.',
      'Refresh your resume and portfolio quarterly so you are not starting from zero under pressure.',
      'Build internal and external networking—coffee chats beat cold applications in downturns.',
      'If rumors swirl, ask your manager calmly about team direction; document commitments that affect you.',
    ],
    'Contract end, layoff, or restructuring exposure': [
      'Know notice periods, severance norms, and visa impacts if applicable; read your contract now, not later.',
      'Save offer letters and bonus terms; they matter if roles are eliminated or regraded.',
      'Identify three target employers or clients you could approach within 30 days if income stops.',
      'Cut discretionary spend preemptively when signals are strong—smaller cuts early beat panic later.',
    ],
    'Dependence on a single employer or client': [
      'Negotiate a second smaller client or internal diversification of projects where possible.',
      'Develop a skill adjacent to your core that another industry values (analytics, writing, ops).',
      'Keep a running brag doc of outcomes so you can pitch elsewhere quickly.',
      'Discuss with household how long you could survive on savings if the sole source vanished.',
    ],
    'Bonus, commission, or irregular pay swings': [
      'Budget to a conservative baseline month; treat upside as savings or debt reduction, not new recurring costs.',
      'Maintain a larger cash buffer proportional to pay variance.',
      'Model taxes on variable income quarterly so April does not erase the “good” months.',
      'If commissions lag policies, get plan documents and examples in email for disputes.',
    ],
    'Dependence on one income stream': [
      'List skills monetizable in 10+ hours a week without quitting—consulting, teaching, gig platforms.',
      'Reduce fixed costs that assume peak earnings (housing, car, private school) if the margin is thin.',
      'Build creditworthiness and emergency savings while employed; both help bridge a transition.',
      'Discuss with partner a staged plan if one income drops (who pauses what, for how long).',
    ],
    'Side work or second-job necessity': [
      'Track hourly pay after tax and commute—sometimes one better primary job beats two mediocre ones.',
      'Automate taxes and separate accounts for side income so you do not spend what you owe.',
      'Protect sleep and recovery; second jobs that destroy health rarely pencil out over a year.',
      'Look for employer tuition or certification support that could replace side hustle hours long term.',
    ],
    'Gap between your skills and where the field is headed': [
      'Read 10 recent job postings you want; list recurring tools and keywords you lack.',
      'Spend 3–5 hours weekly on one learning track with a portfolio artifact at the end.',
      'Pair with a peer learning group or mentor for accountability.',
      'Present a small internal pilot using new skills—visibility beats certificates alone.',
    ],
    'Training or certification you have not kept current': [
      'Calendar renewal deadlines 90 days early; some exams have long booking lags.',
      'Ask employers to sponsor required certs; tie the ask to compliance or revenue risk.',
      'Stack micro-courses toward a credential rather than waiting for a perfect sabbatical.',
      'If a license lapses, map reinstatement steps immediately—waiting multiplies cost.',
    ],
    'Automation or outsourcing risk in your work': [
      'Shift emphasis to judgment, stakeholder management, and cross-domain synthesis—harder to automate.',
      'Learn tools that automate your grunt work so you operate at a higher leverage layer.',
      'Follow where your industry’s budget is moving (cloud, AI copilots, offshore) and skate to that demand.',
      'Maintain an external reputation (talks, posts, OSS) so opportunities exist outside one employer’s roadmap.',
    ],
    'Burnout, hours, or unsustainable pace': [
      'Block non-negotiable rest on calendar like meetings; defend it for four weeks and measure mood.',
      'Escalate scope or deadline conflicts with data (hours, missed milestones) not only feelings.',
      'Cut one recurring meeting or report that adds little value—burnout often has recoverable structural causes.',
      'If burnout is chronic, discuss role change or FMLA/leave options with HR where appropriate.',
    ],
    'Commute or schedule strain': [
      'Test one change (remote day, shifted hours, park-and-ride) for a month and log energy impact.',
      'Negotiate core hours vs. total hours—sometimes flexibility matters more than raw time.',
      'Batch onsite days for collaboration; protect deep work at home if hybrid.',
      'If relocation is on the table, model full cost (rent delta, taxes, partner job) not just salary.',
    ],
    'Fit with manager, team, or culture': [
      'Document specific behaviors and outcomes before a hard conversation; focus on work impact.',
      'Seek a skip-level or HR-mediated chat if direct feedback loops fail.',
      'Invest in one ally relationship cross-team—culture issues are easier with sponsors.',
      'If values misalignment is deep, run a quiet job search; staying erodes performance and health.',
    ],
    'Industry demand and market headwinds': [
      'Follow hiring indices and earnings calls for your sector; early signals beat surprise layoffs.',
      'Diversify industry exposure in skills and network—even a adjacent vertical helps.',
      'Keep liquid savings higher when cyclicality is obvious.',
      'Consider geographic or remote employers outside your local market if demand is soft regionally.',
    ],
    'Regulation, licensing, or policy changes': [
      'Subscribe to professional association alerts for your license or practice area.',
      'Budget time and money for compliance training before deadlines force rush fees.',
      'If policy threatens your niche, prototype a pivot project nights-and-weekends before you must.',
      'Consult a specialist attorney or accountant when rules shift materially—guessing is expensive.',
    ],
    'Geographic or relocation pressure for work': [
      'Model a full household budget in target cities including tax, childcare, and commute.',
      'Negotiate relocation packages explicitly (temp housing, closing costs, tax gross-up).',
      'If you cannot move, hunt fully remote roles in employers licensed in your state.',
      'Discuss partner career impacts openly; dual commutes often fail even when one job is great.',
    ],
  };

  static const Map<String, List<String>> _personalSafety = {
    'Local crime, disorder, or safety where you live': [
      'Walk your block at varied times; note lighting, sightlines, and exit routes.',
      'Introduce yourself to neighbors and local community groups—eyes on the street help.',
      'Report recurring issues (broken lights, dumping) to the right agency with photos and dates.',
      'If you rent, document safety requests to management in writing.',
    ],
    'Routine outings (shops, transit, evenings out)': [
      'Prefer well-lit, populated routes; avoid headphones that block situational awareness.',
      'Keep phone charged; share ETA with someone for late trips.',
      'Park in attended or visible spots; have keys ready before you approach the car.',
      'Plan a safe meetup spot with friends in crowded venues in case you get separated.',
    ],
    'Sense of safety walking alone in your area': [
      'Vary routines slightly so patterns are less predictable.',
      'Carry a small flashlight; shadows and trip hazards matter as much as people risk.',
      'Trust unease—cross the street, enter a store, or call a ride without apologizing for it.',
      'Take a self-defense class focused on de-escalation and escape if you want concrete skills.',
    ],
    'Home break-in or burglary concern': [
      'Upgrade strike plates and deadbolts; reinforce sliding doors; add a video doorbell if budget allows.',
      'Use timers or smart lights when away; pause package delivery during travel.',
      'Record serial numbers and photos of valuables for insurance claims.',
      'Close blinds at night; do not advertise new purchases with packaging at the curb.',
    ],
    'Vehicle theft or vandalism': [
      'Never leave keys or visible bags; lock even for “just a second.”',
      'Prefer garages or attended lots; use a steering lock where theft is common.',
      'Etch VIN on parts if recommended locally; some insurers discount anti-theft devices.',
      'Report incidents promptly; patterns help police allocate patrols.',
    ],
    'Packages, bikes, or storage security': [
      'Use locker hubs or office delivery for high-value items.',
      'Lock bikes through frame and wheel to immovable objects; register serials.',
      'Avoid storage units without good access control; check insurance exclusions.',
      'Label units ambiguously; do not advertise expensive contents.',
    ],
    'Risk of assault, harassment, or targeted harm': [
      'Set clear boundaries early; disengage and leave when someone ignores them.',
      'Save evidence trails (screenshots, logs) if harassment is digital or repeated.',
      'Know local hotlines and workplace reporting paths; use them when behavior crosses lines.',
      'If you fear imminent danger, prioritize escape and emergency services over confrontation.',
    ],
    'Safety in workplaces or schools you use': [
      'Learn evacuation routes and muster points; participate in drills seriously.',
      'Report hazards (doors propped, broken cameras) before an incident.',
      'Use buddy walks to parking at night if your employer allows.',
      'For schools, know pickup protocols and who is authorized—confusion aids predators.',
    ],
    'Conflict or coercion in close relationships (self-assessed)': [
      'If you feel controlled or afraid, contact a local domestic violence hotline—they can safety-plan confidentially.',
      'Keep a go-bag and copies of IDs with someone you trust if leaving might be urgent.',
      'Document incidents with dates; courts and shelters often need patterns, not single events.',
      'Do not meet alone to “talk it out” if violence escalated; choose public or mediated settings.',
    ],
    'Work travel or unfamiliar cities': [
      'Research safe districts and transit before landing; save offline maps.',
      'Share itinerary and hotel details with a contact; check in on a schedule.',
      'Avoid displaying cash or flashy gear; use hotel safes for passports.',
      'Prefer licensed rides from official queues or apps with trip sharing enabled.',
    ],
    'Late-night or isolated routes': [
      'Park under lights near exits; scan back seat before entering.',
      'Let someone track your ride or walk; fake a call if you need an exit excuse.',
      'Avoid ATMs in empty lots; use well-lit vestibules or indoor terminals.',
      'If public transit is sparse, budget occasional rideshares for worst segments.',
    ],
    'Large crowds or events': [
      'Identify exits when you arrive; move perpendicular to crowd surge if panic starts.',
      'Carry minimal valuables; use front pockets or hidden pouches.',
      'Agree on a rendezvous point with your group away from main gates.',
      'Hydrate and pace yourself—medical incidents spike in heat and density.',
    ],
    'How prepared you feel for an emergency': [
      'Build a go-bag with water, meds, copies of IDs, flashlight, and charger.',
      'Run a 10-minute drill: simulate power loss or evacuation with household roles.',
      'Learn basic first aid and CPR; keep kits at home and in vehicles.',
      'Store insurance and medical cards digitally and on paper.',
    ],
    'Communication plan with household': [
      'Pick an out-of-area contact everyone texts if local networks clog.',
      'Teach children who is safe to go with and a code word for emergencies.',
      'Test messaging apps on wifi if cell service is unreliable at home.',
      'Update school and workplace emergency contacts yearly.',
    ],
    'Lighting, locks, and basic security habits': [
      'Fix dark walkways with solar or wired lights on motion sensors.',
      'Lock doors and windows habitually; many intrusions exploit unlocked entries.',
      'Do not hide keys in obvious spots; use lockboxes or smart locks.',
      'Shred documents with addresses; trim bushes that block windows from the street.',
    ],
  };

  static const Map<String, List<String>> _financial = {
    'Runway': [
      'Build or top up a dedicated emergency fund (often discussed as roughly three to six months of essential expenses—adjust to your situation).',
      'Separate “must pay” bills from discretionary spending so you can see true runway if income pauses.',
      'Identify one low-friction way to add to savings automatically (split deposit, scheduled transfer) even if the amount starts small.',
      'List assets you could access within days vs. weeks (cash, money market, short-term savings) so you are not surprised by lock-ups or penalties.',
    ],
    'Net cash flow': [
      'Track inflows and outflows for at least one full month; tag fixed vs. variable expenses.',
      'Pick one recurring expense to reduce or renegotiate (subscriptions, insurance shopping, phone/internet plans).',
      'If cash flow is negative, decide whether to cut spending, raise income, or both—and set one concrete target with a date.',
      'Avoid funding lifestyle growth from credit unless you have a written plan to pay it off within a short, defined window.',
    ],
    'Cash flow volatility': [
      'Average your income over the last 6–12 months if it swings; budget to a conservative “floor” month, not the best month.',
      'Hold a larger liquidity buffer when income is irregular (freelance, commission, seasonal work).',
      'Smooth large predictable expenses (insurance premiums, taxes) with sinking funds or monthly set-asides.',
      'Discuss with household members how you will handle a bad month before one happens (which bills get paid first, what pauses).',
    ],
    'Debt to income': [
      'Write down all debts with balances, minimum payments, and interest rates; update the list quarterly.',
      'Prioritize high-interest debt for extra payments while staying current on all minimums.',
      'Avoid taking new debt for non-essentials until the ratio trends down for several months.',
      'If the ratio is high because income is temporarily low, document a realistic timeline to recovery and protect minimum payments.',
    ],
    'Debt service ratio': [
      'Calculate required monthly debt payments as a share of take-home pay; include BNPL and co-signed obligations if they are yours.',
      'Refinance or consolidate only if the all-in cost (fees, rate, term) clearly improves cash flow—not just a lower payment on a longer leash.',
      'Automate minimum payments on the due date to avoid late fees that silently raise your burden.',
      'Before new borrowing, simulate the new payment inside next month’s budget on paper first.',
    ],
    'Variable rate exposure': [
      'List every loan or line where the rate can move (cards after promo, ARMs, HELOCs, some private student loans).',
      'Model a +1% and +2% rate shock on those payments; decide what you would cut or pay down first if rates rise.',
      'Favor fixing or locking where the fee is reasonable if you need predictable payments for the next few years.',
      'Pay down variable-rate balances ahead of fixed low-rate debt when you expect higher rates and need stability.',
    ],
    'Fixed obligations': [
      'Inventory rent/mortgage, insurance, minimum debt payments, childcare, and other hard-to-cut items.',
      'Challenge each fixed item once a year: still needed? best available price? right deductible or coverage level?',
      'Before signing new long-term contracts, check how they fit if income drops 10–20%.',
      'Build slack by trimming subscriptions and “small” fixed fees—they add up when income is tight.',
    ],
    'Portfolio volatility': [
      'Confirm your time horizon and capacity for loss; volatile assets need longer horizons or smaller position sizes.',
      'Rebalance on a schedule or when allocations drift meaningfully from your target—not after every headline.',
      'Avoid checking balances compulsively; set a review rhythm (e.g. quarterly) aligned with long-term goals.',
      'If volatility causes panic, reduce risk gradually via your policy, not in one emotional trade.',
    ],
    'Drawdown': [
      'Separate “paper” declines from realized losses; avoid selling low to fund lifestyle unless truly necessary.',
      'Keep near-term spending needs out of high-volatility assets so you are not a forced seller in a downturn.',
      'Review whether your risk level still matches life changes (retirement date, job loss, large purchase).',
      'Tax-loss harvesting and contribution timing are advanced topics—consider professional advice before complex moves.',
    ],
    'Risky asset allocation': [
      'Cap single-name or speculative positions as a defined slice of net worth, not the core plan.',
      'Diversify across sectors and geographies unless you have a deliberate concentration thesis and accept the risk.',
      'Use tax-advantaged accounts for high-turnover or high-income strategies where appropriate.',
      'Re-read why you own each risky holding; if you cannot explain it simply, consider simplifying.',
    ],
    'Income concentration': [
      'Track what percent of household income comes from one employer, client, or gig platform.',
      'Develop a second income stream or skill path, even small, that could scale if the primary source fails.',
      'Maintain networking and credentials so a job loss does not start from zero professionally.',
      'Negotiate contracts or employment terms (notice, severance, IP) when you have leverage—not only in a crisis.',
    ],
    'Asset concentration': [
      'Map large positions (employer stock, one rental, one crypto asset, one fund) as a share of total investable assets.',
      'Set a maximum weight per holding and trim toward it on a schedule to reduce timing risk.',
      'Understand liquidity and tax consequences before selling concentrated positions.',
      'If concentration is intentional, document exit rules in advance (e.g. trim above X% of net worth).',
    ],
    'Employer sector coupling': [
      'List links between your paycheck and your investments (company stock, sector ETFs, spouse in same industry).',
      'Reduce overlapping bets: if income depends on tech, avoid having most wealth in the same narrow tech theme.',
      'Prefer broad index funds for core retirement savings when your career is already tied to one sector.',
      'Stress-test: if your industry had a two-year slump, would both income and portfolio suffer together?',
    ],
    'Real return': [
      'Estimate inflation over your planning horizon; compare portfolio expected return to that bar in honest terms.',
      'Favor diversified growth assets for long-term goals; keep only planned short-term money in low-return cash.',
      'Minimize unnecessary fees and taxes—they directly eat real return.',
      'Revisit assumptions after large market moves or life events; do not assume past decade returns repeat.',
    ],
    'Cash exposure': [
      'Decide how much cash is “operating” (bills + buffer) vs. “idle”; move excess toward appropriate investments or debt paydown.',
      'Use high-yield savings or money market for true cash needs; compare rates and FDIC/NCUA limits.',
      'If you fear investing, start with a small recurring amount into a broad low-cost fund while keeping your buffer intact.',
      'Avoid large permanent cash piles unless you have a dated plan to deploy them (purchase, sabbatical, opportunity).',
    ],
    'Inflation mismatch': [
      'Check whether raises, rent, and fixed income sources keep pace with your actual cost basket (housing, healthcare, childcare).',
      'For long horizons, bias savings toward assets with historical inflation-beating behavior, sized to your risk tolerance.',
      'Where possible, fix or escalate major recurring costs consciously (leases, tuition, care) rather than drifting.',
      'Update retirement and education cost assumptions every few years; old numbers quietly become wrong.',
    ],
  };

  static const Map<String, List<String>> _digital = {
    'Password & MFA strength': [
      'Use a reputable password manager to generate long, unique passwords for every important account.',
      'Turn on phishing-resistant MFA (security keys or passkeys) for email, bank, and password-manager accounts where offered.',
      'Retire short, reused, or “keyboard walk” passwords; change any that appeared in a breach (see breach factor too).',
      'Protect the manager itself with a strong master password and MFA; store recovery codes offline in a safe place.',
    ],
    'Recovery & backup codes': [
      'Print or write backup codes and store them offline; do not leave them only in email or cloud notes.',
      'Use a second MFA method when the service allows it so losing one device does not lock you out—or hand control to an attacker.',
      'Review recovery email and phone numbers on critical accounts; remove old numbers and unused recovery addresses.',
      'Practice account recovery once on a low-stakes service so you know the flow before an emergency.',
    ],
    'Shared or reused credentials': [
      'Give housemates or family separate logins or guest profiles instead of sharing your primary passwords.',
      'Rotate passwords on accounts that were ever shared; treat them as potentially known outside your control.',
      'Never reuse passwords across financial, email, and health portals—those are the keys to everything else.',
      'For shared streaming or utilities, use the vendor’s family plan or sub-accounts when available.',
    ],
    'Email & SMS phishing exposure': [
      'Slow down on unexpected links and attachments; verify through an official app or typed URL, not the message.',
      'Turn on spam filters and report phishing to your provider—it improves detection for everyone.',
      'Be skeptical of “delivery,” “invoice,” and “security alert” themes; contact the company via their site directly.',
      'Consider a dedicated email for banking and taxes with minimal signups to reduce exposure.',
    ],
    'Phone & voice scam exposure': [
      'Default rule: banks and government agencies will not ask for passwords or demand gift cards over the phone.',
      'Let unknown numbers go to voicemail; call back using a number from the official website.',
      'Warn household members about grandparent scams, tech-support scams, and fake “fraud department” callbacks.',
      'Register for do-not-call lists where available; block and report persistent scam numbers.',
    ],
    'Urgency or impersonation attempts': [
      'Treat urgency (“in one hour,” “legal action today”) as a red flag; legitimate processes rarely work that way.',
      'Verify identity through a second channel you initiate—not the callback number they give you.',
      'Keep a short script: “I will hang up and call back on the published number.” Practice saying it.',
      'For work, follow your company’s process for wire transfers and vendor changes; ignore one-off “CEO” emails.',
    ],
    'Breach history & leaked passwords': [
      'Check haveibeenpwned.com or your browser’s breach alerts; change passwords on any hit accounts immediately.',
      'Assume leaked passwords are public; never reuse a password that was ever in a breach.',
      'Watch statements for a few months after a breach; enable alerts on bank and card accounts.',
      'Freeze or lock credit reports when identity theft is a concern (process varies by country).',
    ],
    'Cross-site password reuse': [
      'Prioritize unique passwords for email, banking, brokerage, health, and SSO accounts you use everywhere.',
      'Run a password-manager audit for duplicates; fix the riskiest five first.',
      'When you cannot migrate everything at once, start with accounts that can reset others (email first).',
      'Delete old accounts you no longer use so they cannot be stuffed with reused credentials later.',
    ],
    'Sensitive data in email or storage': [
      'Move tax returns, IDs, and medical documents to encrypted storage or a vault with access controls.',
      'Remove sensitive attachments from email inboxes and sent folders; empty trash and archive consciously.',
      'Turn off automatic cloud backup for photos if they may capture cards, IDs, or sensitive screenshots.',
      'Use end-to-end encrypted channels when you must share secrets; avoid “security by obscurity” in plain email.',
    ],
    'Device lock & encryption': [
      'Enable screen lock with PIN/biometrics on phone and laptop; shorten auto-lock timeout on mobile.',
      'Turn on full-disk encryption (FileVault, BitLocker, Android equivalent) on laptops you travel with.',
      'Require authentication for password manager and banking apps; disable lock-screen notification previews if they leak OTPs.',
      'Wipe or factory-reset devices before resale or recycling.',
    ],
    'Software updates & patching': [
      'Enable automatic updates for OS and browsers; reboot when prompted so patches actually apply.',
      'Update router firmware occasionally; change default admin passwords on home routers.',
      'Remove unused browser extensions; they are a common malware path.',
      'For critical work machines, schedule a monthly “maintenance window” if you tend to defer updates.',
    ],
    'Public Wi‑Fi & untrusted networks': [
      'Treat coffee-shop and hotel Wi‑Fi as observable; avoid logging into sensitive accounts unless necessary.',
      'Use cellular data or a reputable VPN for banking on the road when you must connect.',
      'Forget public networks after use; disable auto-join for unknown SSIDs.',
      'Verify hotspot names with staff; attackers often broadcast similar network names.',
    ],
    'Social & public oversharing': [
      'Review profile visibility on social platforms; remove public birth year, address hints, and travel-in-real-time posts.',
      'Avoid posting photos of IDs, boarding passes, keys, or badges—each helps impersonation or physical risk.',
      'Teach family the same habits; kids’ accounts often leak family routines.',
      'Google yourself occasionally; remove or request takedown of data-broker listings where laws allow.',
    ],
    'Location & tracking exposure': [
      'Turn off unnecessary location permissions; use “while using app” instead of “always” unless truly needed.',
      'Limit ad tracking and reset advertising IDs periodically in OS privacy settings.',
      'Disable geotagging on photos you share publicly if you do not want place history mined.',
      'Review which apps accessed location recently; revoke access from apps you barely use.',
    ],
    'Third‑party app permissions': [
      'Audit installed apps quarterly; uninstall what you do not use.',
      'Revoke camera, microphone, contacts, and SMS access unless the app has a clear need.',
      'Prefer sign-in with Apple’s hide-my-email or per-site emails when offered to reduce cross-linking.',
      'Read permission prompts slowly on install; “later” is often safer than “allow all.”',
    ],
  };
}
