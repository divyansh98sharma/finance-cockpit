const moneyFormatter = new Intl.NumberFormat("en-IN", {
  style: "currency",
  currency: "INR",
  maximumFractionDigits: 0,
});

const dueSoon = [
  {
    name: "ICICI Amazon Pay",
    amount: 18450,
    due: "28 Apr",
    confidence: "Confirmed",
  },
  {
    name: "Kotak Credit Card",
    amount: 9200,
    due: "02 May",
    confidence: "Needs review",
  },
  {
    name: "Rent",
    amount: 42000,
    due: "05 May",
    confidence: "Manual",
  },
];

const activity = [
  ["Kotak salary credit", 185000, "Income"],
  ["CRED QR payment", -820, "UPI"],
  ["ICICI Coral fuel", -2400, "Card"],
  ["Mutual fund SIP", -15000, "Investment"],
];

const stages = [
  ["Vault", "Store PDFs, CSVs, Excel files, screenshots, and images locally."],
  ["Parser", "Extract normalized records with deterministic and AI-assisted paths."],
  ["Review", "Route uncertain imports into a correction inbox before ledger merge."],
  ["Engine", "Compute safe-to-spend, dues, debt pressure, and nudges."],
];

export default function Home() {
  return (
    <main className="min-h-screen bg-stone-50 text-slate-950">
      <section className="mx-auto flex min-h-screen w-full max-w-7xl flex-col px-5 py-5 sm:px-8 lg:px-10">
        <header className="flex flex-col gap-4 border-b border-slate-200 pb-5 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase tracking-[0.18em] text-emerald-700">
              Finance Cockpit
            </p>
            <h1 className="mt-2 text-3xl font-semibold tracking-normal text-slate-950 sm:text-5xl">
              Daily money control, locally.
            </h1>
          </div>
          <div className="flex items-center gap-2 text-sm text-slate-600">
            <span className="h-2.5 w-2.5 rounded-full bg-emerald-600" />
            Local-first V1 foundation
          </div>
        </header>

        <div className="grid flex-1 gap-6 py-6 lg:grid-cols-[1.15fr_0.85fr]">
          <section className="flex flex-col justify-between rounded-md border border-slate-200 bg-white p-5 shadow-sm sm:p-7">
            <div className="flex items-start justify-between gap-5">
              <div>
                <p className="text-sm font-medium text-slate-500">
                  Safe to spend today
                </p>
                <p className="mt-3 text-5xl font-semibold tracking-normal text-slate-950 sm:text-7xl">
                  {moneyFormatter.format(2450)}
                </p>
              </div>
              <div className="rounded-md bg-amber-100 px-3 py-2 text-sm font-medium text-amber-900">
                Sample data
              </div>
            </div>

            <div className="mt-10 grid gap-3 sm:grid-cols-3">
              <Metric label="Usable cash" value={moneyFormatter.format(142000)} />
              <Metric label="Upcoming dues" value={moneyFormatter.format(69650)} />
              <Metric label="Debt pressure" value={moneyFormatter.format(28500)} />
            </div>

            <div className="mt-8 border-t border-slate-200 pt-5">
              <p className="text-sm font-medium text-slate-500">Next action</p>
              <p className="mt-2 text-xl font-semibold text-slate-950">
                Pay {moneyFormatter.format(18450)} to ICICI Amazon Pay before 28 Apr.
              </p>
            </div>
          </section>

          <section className="rounded-md border border-slate-200 bg-white p-5 shadow-sm sm:p-7">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold">Due soon</h2>
              <span className="text-sm text-slate-500">3 obligations</span>
            </div>

            <div className="mt-5 divide-y divide-slate-200">
              {dueSoon.map((item) => (
                <div
                  className="flex items-center justify-between gap-4 py-4"
                  key={item.name}
                >
                  <div>
                    <p className="font-medium text-slate-950">{item.name}</p>
                    <p className="mt-1 text-sm text-slate-500">
                      {item.due} · {item.confidence}
                    </p>
                  </div>
                  <p className="font-semibold text-slate-950">
                    {moneyFormatter.format(item.amount)}
                  </p>
                </div>
              ))}
            </div>
          </section>

          <section className="rounded-md border border-slate-200 bg-white p-5 shadow-sm sm:p-7">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold">Unified activity</h2>
              <span className="text-sm text-slate-500">Ledger preview</span>
            </div>
            <div className="mt-5 overflow-hidden rounded-md border border-slate-200">
              {activity.map(([label, amount, type]) => (
                <div
                  className="grid grid-cols-[1fr_auto] gap-4 border-b border-slate-200 px-4 py-3 last:border-b-0 sm:grid-cols-[1fr_120px_110px]"
                  key={label}
                >
                  <span className="font-medium text-slate-800">{label}</span>
                  <span
                    className={
                      Number(amount) > 0
                        ? "font-semibold text-emerald-700"
                        : "font-semibold text-slate-950"
                    }
                  >
                    {moneyFormatter.format(Number(amount))}
                  </span>
                  <span className="hidden text-right text-sm text-slate-500 sm:block">
                    {type}
                  </span>
                </div>
              ))}
            </div>
          </section>

          <section className="rounded-md border border-slate-200 bg-slate-950 p-5 text-white shadow-sm sm:p-7">
            <h2 className="text-xl font-semibold">Build slices</h2>
            <div className="mt-5 grid gap-4">
              {stages.map(([title, description]) => (
                <div className="border-l border-emerald-400 pl-4" key={title}>
                  <p className="font-semibold">{title}</p>
                  <p className="mt-1 text-sm leading-6 text-slate-300">
                    {description}
                  </p>
                </div>
              ))}
            </div>
          </section>
        </div>
      </section>
    </main>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-md border border-slate-200 bg-stone-50 p-4">
      <p className="text-sm text-slate-500">{label}</p>
      <p className="mt-2 text-2xl font-semibold text-slate-950">{value}</p>
    </div>
  );
}
