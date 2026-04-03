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
    // Single-section categories (title matches CategorySection)
    'Health':
        'Your overall health-related risk in this dashboard: how health issues, costs, '
        'prevention, and insurance fit together—not a medical diagnosis.',
    'Career':
        'Your overall work and income stability risk: job security, pay swings, skills, '
        'stress, and outside forces on your field.',
    'Personal Safety':
        'Your exposure to crime, theft, and personal harm where you live and spend time. '
        'It reflects how you perceive risk, not official crime statistics.',
    'Digital / Privacy':
        'Your exposure to scams, account theft, weak security, and oversharing online. '
        'High risk means more ways something digital could go wrong.',
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
    // Health
    'Chronic & acute health load':
        'Ongoing conditions or serious health events you carry. Higher means more health '
        'burden on daily life and costs.',
    'Healthcare cost sensitivity':
        'How much a big medical bill or premium jump would hurt your budget. Higher means '
        'less room to absorb cost shocks.',
    'Preventive care gaps':
        'Checkups, screenings, and habits you might be skipping. Gaps can mean problems '
        'show up later and cost more.',
    'Coverage & access adequacy':
        'Whether insurance and getting care when you need it feel sufficient. Low scores '
        'mean worry about paying for or reaching care.',
    // Career
    'Role & job security':
        'How stable your job or role feels—layoffs, contract end, or org change. '
        'Higher risk means more uncertainty about keeping income.',
    'Income / bonus volatility':
        'How much your pay changes month to month or year to year. Big swings make '
        'budgeting and saving harder.',
    'Skills & training gap':
        'How well your skills match where your industry is going. A gap means harder '
        'job moves or pay growth later.',
    'Workload & burnout':
        'Stress, hours, and whether the pace feels sustainable. High risk means burnout '
        'could affect health and performance.',
    'Industry & market headwinds':
        'Outside forces on your field—automation, regulation, demand drops. Higher means '
        'the sector itself feels shaky.',
    // Personal safety
    'Neighborhood & local incidents':
        'Crime, disorder, or safety issues where you live or spend time regularly. '
        'Based on how you perceive local risk.',
    'Property / theft exposure':
        'Risk of break-ins, theft, or property crime affecting you or your home.',
    'Personal violence exposure':
        'Your sense of risk of physical harm or violence directed at you in daily life.',
    // Digital / privacy
    'Password & MFA hygiene':
        'Strength and reuse of passwords and whether you use two-factor authentication. '
        'Weak habits make account takeover easier.',
    'Phishing & scams exposure':
        'How often you face fake emails, texts, or calls trying to steal info or money. '
        'Higher exposure means more chances to slip up.',
    'Data breach & account reuse':
        'Past leaks and using the same password on many sites. Reuse means one breach '
        'can unlock multiple accounts.',
    'Device & network security':
        'Phones, laptops, updates, and Wi‑Fi safety. Outdated or public networks increase '
        'chance of snooping or malware.',
    'Oversharing & trace footprint':
        'How much personal detail you put online where strangers or scammers can use it.',
  };
}
