/// Plain-language tooltips for subcategory section titles and individual factors.
/// Keys must match UI strings exactly.
abstract final class RiskHelpText {
  static String? subcategory(String title) => _subcategory[title];

  static String? factor(String label) => _factor[label];

  static const Map<String, String> _subcategory = {
    // Financial (section titles)
    'Liquidity and cash flow':
        'How easily you can cover bills and surprises with cash and short-term savings. '
        'High risk here means a thin cushion or shaky inflows and outflows.',
    'Obligations and leverage':
        'How heavy debt payments and fixed bills are compared to what you earn. '
        'High risk means payments take a large share of income or could jump if rates change.',
    'Asset risk':
        'How much your investments swing up and down, and how exposed you are to losses. '
        'High risk means volatile holdings or big drawdowns relative to what you can tolerate.',
    'Concentration risk':
        'How much depends on one job, one employer, one asset, or one income stream. '
        'High risk means if that one piece fails, a lot of your finances are hit at once.',
    'Inflation and purchasing power':
        'Whether your savings and returns keep up with the cost of living over time. '
        'High risk means too much idle cash or returns that lag inflation.',
    // Health (section titles)
    'Physical health burden':
        'Conditions, symptoms, sleep, and energy as you experience them—not a diagnosis. '
        'Higher means more day-to-day health load on your life.',
    'Prevention & access':
        'Screenings you delay, wait times, and practical barriers to care. '
        'Higher means prevention and access feel harder to sustain.',
    'Costs & coverage':
        'Bills, insurance gaps, and affordability of treatment. '
        'Higher means financial shock from care is a bigger worry.',
    'Mental load & behavior':
        'Stress, mood, habits, and support. Higher means mental strain or risky habits '
        'weigh more on overall wellbeing.',
    'Dependents & caregiving':
        'Others who rely on you for health and care, and the time or burnout that takes. '
        'Higher means dependent needs feel heavy or under-planned.',
    // Career (section titles)
    'Role & employment stability':
        'Job security, contracts, and reliance on one employer or client. '
        'Higher means income continuity feels less certain.',
    'Income & volatility':
        'Bonus swings, single-stream dependence, and need for side work. '
        'Higher means pay is harder to predict or lean on one source.',
    'Skills & relevance':
        'Keeping skills current versus where your field is headed. '
        'Higher means obsolescence or retraining pressure feels real.',
    'Workload & sustainability':
        'Hours, burnout risk, commute, and workplace fit. '
        'Higher means the pace or environment feels hard to sustain.',
    'Industry & external risk':
        'Demand, regulation, and geography affecting your sector. '
        'Higher means outside forces could disrupt your work.',
    // Personal safety (section titles)
    'Neighborhood & everyday exposure':
        'How safe routine places and your area feel to you—not crime statistics.',
    'Property & theft':
        'Break-ins, vehicle crime, and securing belongings you care about.',
    'Personal violence & conflict':
        'Assault, harassment, workplace or school safety, and coercion in close relationships '
        '(self-assessed, subjective).',
    'Travel & unfamiliar places':
        'Work travel, night routes, crowds, and unfamiliar environments.',
    'Awareness & readiness':
        'Emergency prep, household communication, and basic security habits.',
    'Identity & authentication':
        'How strong your logins are: passwords, MFA, recovery options, and whether '
        'credentials are shared or reused. Weak spots here make takeover much easier.',
    'Phishing & social engineering':
        'How often you are targeted by fake messages, calls, or pressure tactics. '
        'Higher exposure means more chances someone tricks you into giving access.',
    'Data exposure & account hygiene':
        'Past leaks, password reuse, and where sensitive data lives (email, drives, chats). '
        'Poor hygiene means one incident spreads across accounts.',
    'Devices & networks':
        'Locks, encryption, updates, and the networks you trust. '
        'Outdated devices or risky Wi‑Fi increase malware and snooping risk.',
    'Privacy & footprint':
        'What you reveal publicly online, tracking, and app permissions. '
        'A large footprint gives scammers and advertisers more to work with.',
  };

  static const Map<String, String> _factor = {
    // Financial — liquidity
    'Runway':
        'Roughly how long you could keep paying essential bills if income stopped, '
        'using cash and savings you can access quickly.',
    'Net cash flow':
        'Whether money left over after typical spending is positive and steady, or tight '
        'or negative most months.',
    'Cash flow volatility':
        'How much your income or expenses bounce around month to month. More swings '
        'mean harder planning and more stress.',
    // Financial — obligations
    'Debt to income':
        'How large your debts are compared to what you earn. Higher usually means more '
        'strain if income drops.',
    'Debt service ratio':
        'How much of your income goes to required debt payments each month. A high share '
        'leaves less room for savings and surprises.',
    'Variable rate exposure':
        'How much your payments could rise if interest rates go up, for example on '
        'adjustable loans or lines of credit.',
    'Fixed obligations':
        'Rent, subscriptions, insurance, and other bills you must pay even in a bad month. '
        'Heavy fixed costs are harder to cut quickly.',
    // Financial — asset risk
    'Portfolio volatility':
        'How much your investment balances move up and down. More movement means more '
        'uncertainty and possible stress.',
    'Drawdown':
        'How bad a past or possible drop in your portfolio value could feel versus your '
        'goals and timeline.',
    'Risky asset allocation':
        'How much of your money is in things that can lose a lot quickly (e.g. volatile '
        'stocks, crypto, concentrated bets).',
    // Financial — concentration
    'Income concentration':
        'How much of your household income comes from one job, client, or source. '
        'One source means one failure hurts everything.',
    'Asset concentration':
        'How much wealth sits in one stock, property, or asset type. Less spread out means '
        'bigger loss if that piece drops.',
    'Employer sector coupling':
        'How tied your income and investments are to the same industry or employer. '
        'If both go bad together, risk stacks up.',
    // Financial — inflation
    'Real return':
        'Return on savings and investments after inflation. If real return is low or '
        'negative, purchasing power shrinks over time.',
    'Cash exposure':
        'How much sits in cash or equivalents that barely grows. Some cash is good; too '
        'much can lose to inflation.',
    'Inflation mismatch':
        'Whether your income, savings, and future costs line up with rising prices. '
        'A mismatch means your money buys less over time.',
    // Health — factors
    'Chronic or acute conditions you manage':
        'Ongoing diagnoses or flare-ups you live with. Higher means they take more attention, '
        'energy, or planning day to day.',
    'Day-to-day pain, fatigue, or symptoms':
        'How often pain, tiredness, or symptoms limit activity or mood—not a clinical score.',
    'Sleep quality and energy most weeks':
        'Whether rest and energy feel adequate for what you need to do. Poor sleep often '
        'amplifies other health stress.',
    'Preventive care and screenings you skip or delay':
        'Checkups, dental, vision, vaccines, or screenings you put off. Delays can mean '
        'issues are caught later.',
    'Wait times, referrals, or specialist access':
        'How hard it is to get timely appointments or the right specialist when needed.',
    'Distance, cost, or logistics blocking care':
        'Travel, childcare, time off work, or money making care harder to use.',
    'Sensitivity to a large medical bill':
        'How painful a surprise bill would be relative to your buffer and income.',
    'Gaps in insurance vs. what you might need':
        'Deductibles, exclusions, networks, or coverage limits that worry you if something serious happened.',
    'Prescription and ongoing treatment affordability':
        'Cost of meds, supplies, or therapy you need to keep taking.',
    'Stress, anxiety, or low mood impact on life':
        'How much mental strain affects work, relationships, or daily function (self-reported).',
    'Habits that could affect health (sleep, substance, etc.)':
        'Patterns you notice (sleep, alcohol, smoking, food, screen time) that might raise risk over time.',
    'Social support when things get hard':
        'Whether you have people to lean on practically or emotionally in a health crisis.',
    'Health needs of children or elders you support':
        'Dependents whose medical or daily care needs fall partly on you.',
    'Caregiving time and burnout risk':
        'Hours and emotional load of supporting someone else’s health.',
    'Coverage and planning for dependents’ care':
        'Insurance, savings, or legal plans for dependents’ healthcare if something changes.',
    // Career — factors
    'Job or role security over the next year':
        'How likely you feel layoff, non-renewal, or major role change is in the near term.',
    'Contract end, layoff, or restructuring exposure':
        'Specific events (contract dates, rumors, org change) that could interrupt income.',
    'Dependence on a single employer or client':
        'How much of your livelihood rides on one relationship or paycheck.',
    'Bonus, commission, or irregular pay swings':
        'How much take-home varies with performance, season, or luck.',
    'Dependence on one income stream':
        'Household reliance on a single job or gig without backup.',
    'Side work or second-job necessity':
        'Whether you need extra work to cover basics—not optional “fun” income.',
    'Gap between your skills and where the field is headed':
        'How aligned your capabilities are with tools, roles, or demand you see emerging.',
    'Training or certification you have not kept current':
        'Licenses, certs, or training that are stale or missing versus job postings you care about.',
    'Automation or outsourcing risk in your work':
        'How much of what you do could be automated, offshored, or consolidated away.',
    'Burnout, hours, or unsustainable pace':
        'Whether workload feels chronically too high to recover from week to week.',
    'Commute or schedule strain':
        'Time, cost, or inflexibility of getting to work or juggling shifts.',
    'Fit with manager, team, or culture':
        'Conflict, isolation, or mismatch that makes staying healthy at work harder.',
    'Industry demand and market headwinds':
        'Whether employers in your field are hiring, stable, or cutting back.',
    'Regulation, licensing, or policy changes':
        'Rules that could change how you practice, bill, or operate professionally.',
    'Geographic or relocation pressure for work':
        'Need to move, commute farther, or accept a worse location to keep opportunities.',
    // Personal safety — factors
    'Local crime, disorder, or safety where you live':
        'How you perceive safety around home—noise, drugs, vandalism, or violent incidents.',
    'Routine outings (shops, transit, evenings out)':
        'Everyday places where you spend time and how safe they feel.',
    'Sense of safety walking alone in your area':
        'Comfort moving on foot locally, especially at night or in quiet areas.',
    'Home break-in or burglary concern':
        'Worry about forced entry, theft while away, or unsecured entry points.',
    'Vehicle theft or vandalism':
        'Risk to cars, bikes, or vehicles you park on street or in lots.',
    'Packages, bikes, or storage security':
        'Porch pirates, shared storage, or unsecured bikes and gear.',
    'Risk of assault, harassment, or targeted harm':
        'Your sense of exposure to intentional harm or harassment directed at you.',
    'Safety in workplaces or schools you use':
        'Security, bullying, or conflict in places you must go regularly.',
    'Conflict or coercion in close relationships (self-assessed)':
        'Feeling unsafe or controlled in relationships—seek professional help if you are in danger.',
    'Work travel or unfamiliar cities':
        'Trips where you are less familiar with risks, transit, or neighborhoods.',
    'Late-night or isolated routes':
        'Walking, parking, or transit when few people are around.',
    'Large crowds or events':
        'Concerts, transit hubs, or protests where density or chaos raises concern.',
    'How prepared you feel for an emergency':
        'Confidence you could respond to fire, medical, or security emergencies at home.',
    'Communication plan with household':
        'Whether people know how to reach each other and where to go if separated.',
    'Lighting, locks, and basic security habits':
        'Physical deterrence and routines (locks, lights, awareness) you actually use.',
    // Digital / privacy (sub-factors)
    'Password & MFA strength':
        'How hard your passwords are to guess and whether MFA protects important accounts.',
    'Recovery & backup codes':
        'Whether recovery email, codes, or backup methods could let an attacker in '
        'if your phone or inbox is compromised.',
    'Shared or reused credentials':
        'Family logins, shared streaming accounts, or the same password on many sites. '
        'Sharing multiplies who can access what.',
    'Email & SMS phishing exposure':
        'Volume and realism of fake links and messages you see. More exposure means '
        'more opportunities to click the wrong thing.',
    'Phone & voice scam exposure':
        'Robocalls, fake support, and impersonation over the phone or voicemail.',
    'Urgency or impersonation attempts':
        'Messages that rush you (“act now”) or pretend to be your bank, employer, or IRS. '
        'These tactics bypass careful thinking.',
    'Breach history & leaked passwords':
        'Whether your accounts or emails have appeared in known leaks. Past leaks raise '
        'reuse and credential-stuffing risk.',
    'Cross-site password reuse':
        'Using the same password across shopping, email, and work. One breach can cascade.',
    'Sensitive data in email or storage':
        'Tax docs, IDs, or secrets sitting in email, cloud folders, or unencrypted drives.',
    'Device lock & encryption':
        'Screen locks, full-disk encryption, and what happens if a device is lost or stolen.',
    'Software updates & patching':
        'How current OS and apps are. Skipped updates leave known holes open.',
    'Public Wi‑Fi & untrusted networks':
        'Coffee-shop Wi‑Fi, hotel networks, or unknown hotspots where traffic can be watched.',
    'Social & public oversharing':
        'Personal details visible on social profiles, forums, or public posts scammers mine.',
    'Location & tracking exposure':
        'Location sharing, ad tracking, and apps that always know where you are.',
    'Third‑party app permissions':
        'Camera, contacts, and broad access granted to apps you barely use.',
  };
}
