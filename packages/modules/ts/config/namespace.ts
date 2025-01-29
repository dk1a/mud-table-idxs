import { ErrorMessage, flatMorph, show } from "@ark/util";
import { hasOwnKey, mergeIfUndefined, Namespace, Store } from "@latticexyz/store/internal";
import { NamespaceInput } from "./input";
import { resolveTables, validateTables } from "./tables";

export type validateNamespace<input, storeConfig extends Store, namespaceLabel extends string> = {
  [key in keyof input]: key extends "tables"
    ? validateTables<input[key], storeConfig, namespaceLabel>
    : key extends keyof NamespaceInput
      ? NamespaceInput[key]
      : ErrorMessage<`\`${key & string}\` is not a valid namespace config option.`>;
};

export function validateNamespace<storeNamespace extends Namespace>(
  input: unknown,
  storeNamespace: storeNamespace,
): asserts input is NamespaceInput {
  if (hasOwnKey(input, "namespace") && typeof input.namespace === "string" && input.namespace.length > 14) {
    throw new Error(`\`namespace\` must fit into a \`bytes14\`, but "${input.namespace}" is too long.`);
  }
  if (hasOwnKey(input, "tables")) {
    validateTables(input.tables, storeNamespace.tables);
  }
}

export type resolveNamespace<input, storeNamespace extends Namespace> = input extends NamespaceInput
  ? {
      readonly tables: undefined extends input["tables"]
        ? Record<string, never>
        : show<
            resolveTables<
              {
                readonly [label in keyof input["tables"]]: mergeIfUndefined<
                  input["tables"][label],
                  Record<string, never>
                >;
              },
              storeNamespace["tables"]
            >
          >;
    }
  : never;

export function resolveNamespace<const input extends NamespaceInput, storeNamespace extends Namespace>(
  input: input,
  storeNamespace: storeNamespace,
): resolveNamespace<input, storeNamespace> {
  return {
    tables: resolveTables(
      flatMorph(input.tables ?? {}, (label, table) => {
        return [label, mergeIfUndefined(table, {})];
      }),
      storeNamespace.tables,
    ),
  } as never;
}
