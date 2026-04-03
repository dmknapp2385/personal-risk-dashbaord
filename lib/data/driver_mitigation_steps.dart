import '../models/driver_factor.dart';
import '../models/risk_category.dart';

/// Actionable mitigation bullets keyed by exact factor labels for Financial and
/// Digital / Privacy. Other categories return a short placeholder until modeled.
abstract final class DriverMitigationSteps {
  static const List<String> _otherCategoryPlaceholder = [
    'Tailored “next steps” for this category are not in the app yet. Open the tab, '
        're-read each question, and lower levels where they no longer match reality. '
        'We will add specific guidance here soon.',
  ];

  /// Bullets to show for this driver (financial and digital are fully covered).
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
      case RiskCategory.career:
      case RiskCategory.personalSafety:
        return _otherCategoryPlaceholder;
    }
  }

  static bool hasFullPlaybook(RiskCategory category) =>
      category == RiskCategory.financial ||
      category == RiskCategory.digitalPrivacy;

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
