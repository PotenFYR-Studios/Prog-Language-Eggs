/** Startup-variable table (SPEC §5.7 table styling) fed only by real egg
 *  variables from catalog.json. */
export interface EggVariable {
  name: string;
  env_variable: string;
  default_value: string;
  description: string;
  rules: string;
  user_viewable: boolean;
  user_editable: boolean;
}

export function VarTable({ rows }: { rows: EggVariable[] }) {
  return (
    <div className="var-table-wrap my-4">
      <table className="var-table">
        <thead>
          <tr>
            <th>Variable</th>
            <th>Default</th>
            <th>Editable</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((v) => (
            <tr key={v.env_variable}>
              <td>
                <code>{v.env_variable}</code>
              </td>
              <td className="whitespace-nowrap font-mono text-[0.78em] text-ink-2">
                {v.default_value === "" ? (
                  <span className="text-faint">-</span>
                ) : (
                  v.default_value
                )}
              </td>
              <td className="whitespace-nowrap">
                {v.user_editable ? (
                  <span className="text-brand-emerald">yes</span>
                ) : (
                  <span className="text-faint">panel</span>
                )}
              </td>
              <td>{v.description}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
