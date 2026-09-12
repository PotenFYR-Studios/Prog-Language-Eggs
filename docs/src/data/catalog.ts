import catalogJson from "./catalog.json";

export interface EggVariable {
  name: string;
  env_variable: string;
  default_value: string;
  description: string;
  rules: string;
  user_viewable: boolean;
  user_editable: boolean;
  field_type: string;
}

export interface LanguageRow {
  n: number;
  name: string;
  runners: string;
  managers: string;
  triggers: string;
}

export interface Catalog {
  generated_at: string;
  sources: string[];
  egg: {
    name: string;
    author: string;
    description: string;
    ptdl_version: string;
    update_url: string;
    exported_at: string;
    features: string[];
    docker_images: Record<string, string>;
    startup: string;
    stop: string;
    startup_done_matchers: string[];
    install_container: string;
    install_entrypoint: string;
    file_denylist: string[];
    variables: EggVariable[];
    variable_count: number;
  };
  languages: LanguageRow[];
  language_count: number;
}

export const catalog = catalogJson as Catalog;

/** Variable lookup by env name, the only sanctioned way to reference an
 *  egg variable in page copy (keeps docs in sync with the real JSON). */
export function eggVar(env: string): EggVariable {
  const v = catalog.egg.variables.find((x) => x.env_variable === env);
  if (!v) throw new Error(`prebuild: unknown egg variable ${env}`);
  return v;
}
