import { ErrorMessage, show } from "@ark/util";
import { Store } from "@latticexyz/store";
import { hasOwnKey } from "@latticexyz/store/internal";
import { StoreIdxsInput } from "./input";
import { validateNamespaces, resolveNamespaces } from "./namespaces";

export type validateStoreIdxs<input, storeConfig extends Store> = {
  [key in keyof input]: key extends "namespaces"
    ? storeConfig["multipleNamespaces"] extends false
      ? ErrorMessage<"Idxs can only be used with multipleNamespaces mode of the store config.">
      : validateNamespaces<input[key], storeConfig>
    : // TODO figure out what's going on, remove the magic if possible
      // the condition isn't important, but `input[key]` here is even if it's never reached,
      // otherwise namespaces is inferred as an empty record
      key extends "magic"
      ? input[key]
      : ErrorMessage<`\`${key & string}\` is not a valid StoreIdxs config option.`>;
};

export function validateStoreIdxs(input: unknown, storeConfig: Store): asserts input is StoreIdxsInput {
  if (hasOwnKey(input, "namespaces")) {
    if (!hasOwnKey(storeConfig, "namespaces")) {
      throw new Error("Idxs can only be used with multipleNamespaces mode of the store config.");
    }
    validateNamespaces(input.namespaces, storeConfig.namespaces);
  }
}

export type resolveStoreIdxs<input, storeConfig extends Store> = {
  readonly namespaces: "namespaces" extends keyof input
    ? show<resolveNamespaces<input["namespaces"], storeConfig["namespaces"]>>
    : Record<string, never>;
};

export function resolveStoreIdxs<const input extends StoreIdxsInput, storeConfig extends Store>(
  input: input,
  storeConfig: storeConfig,
): resolveStoreIdxs<input, storeConfig> {
  return {
    namespaces: resolveNamespaces(input.namespaces ?? {}, storeConfig.namespaces),
  } as never;
}

export function defineStoreIdxs<const input, storeConfig extends Store>(
  input: validateStoreIdxs<input, storeConfig>,
  storeConfig: storeConfig,
): show<resolveStoreIdxs<input, storeConfig>> {
  validateStoreIdxs(input, storeConfig);
  return resolveStoreIdxs(input, storeConfig) as never;
}
