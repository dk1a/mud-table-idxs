import { ErrorMessage, flatMorph } from "@ark/util";
import { get, hasOwnKey, isObject, mergeIfUndefined, Namespaces, Store } from "@latticexyz/store/internal";
import { NamespacesInput } from "./input";
import { validateNamespace, resolveNamespace } from "./namespace";

export type validateNamespaces<namespaces, storeConfig extends Store> = {
  [label in keyof namespaces]: label extends string
    ? label extends keyof storeConfig["namespaces"]
      ? validateNamespace<namespaces[label], storeConfig, label>
      : ErrorMessage<`Namespace \`${label & string}\` does not exist in the referenced store config.`>
    : ErrorMessage<`Expected namespace keys to be strings.`>;
};

export function validateNamespaces<storeNamespaces extends Namespaces>(
  input: unknown,
  storeNamespaces: storeNamespaces,
): asserts input is NamespacesInput {
  if (!isObject(input)) {
    throw new Error(`Expected namespaces, received ${JSON.stringify(input)}`);
  }
  for (const label of Object.keys(input)) {
    if (!hasOwnKey(storeNamespaces, label)) {
      throw new Error(`Namespace \`${label}\` does not exist in the referenced store config.`);
    }

    const namespace: unknown = get(input, label);
    validateNamespace(namespace, storeNamespaces[label]);
  }
}

export type resolveNamespaces<namespaces, storeNamespaces extends Namespaces> = {
  readonly [label in keyof namespaces]: resolveNamespace<
    mergeIfUndefined<namespaces[label], Record<string, never>>,
    label extends string ? storeNamespaces[label] : never
  >;
};

export function resolveNamespaces<input extends NamespacesInput, storeNamespaces extends Namespaces>(
  input: input,
  storeNamespaces: storeNamespaces,
): resolveNamespaces<input, storeNamespaces> {
  if (!isObject(input)) {
    throw new Error(`Expected namespaces config, received ${JSON.stringify(input)}`);
  }

  const namespaces = flatMorph(input as NamespacesInput, (label, namespace) => [
    label,
    resolveNamespace(mergeIfUndefined(namespace, {}), storeNamespaces[label]),
  ]);

  return namespaces as never;
}
