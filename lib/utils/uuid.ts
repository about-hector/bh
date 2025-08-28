// UUID utility extracted from the minified code
let randomUUIDSource: { randomUUID?: () => string } = {};

if (typeof crypto !== "undefined" && crypto.randomUUID) {
  randomUUIDSource.randomUUID = crypto.randomUUID.bind(crypto);
}

const uuid4Bytes = new Uint8Array(16);
let getRandomValues: ((arr: Uint8Array) => Uint8Array) | undefined;

const byteToHex: string[] = [];
for (let i = 0; i < 256; ++i) {
  byteToHex.push((i + 256).toString(16).slice(1));
}

export function uuid(options?: any, buffer?: any, offset?: number): string {
  if (randomUUIDSource.randomUUID && !buffer && !options) {
    return randomUUIDSource.randomUUID();
  }

  const randomBytes =
    (options = options || {}).random ||
    (
      options.rng ||
      function () {
        if (!getRandomValues) {
          if (typeof crypto === "undefined" || !crypto.getRandomValues) {
            throw new Error(
              "crypto.getRandomValues() not supported. See https://github.com/uuidjs/uuid#getrandomvalues-not-supported",
            );
          }
          getRandomValues = crypto.getRandomValues.bind(crypto);
        }
        return getRandomValues(uuid4Bytes);
      }
    )();

  // Set version (4) and variant bits
  randomBytes[6] = (randomBytes[6] & 0x0f) | 0x40;
  randomBytes[8] = (randomBytes[8] & 0x3f) | 0x80;

  if (buffer) {
    offset = offset || 0;
    for (let i = 0; i < 16; ++i) {
      buffer[offset + i] = randomBytes[i];
    }
    return buffer;
  }

  return unsafeStringify(randomBytes);
}

function unsafeStringify(arr: Uint8Array, offset = 0): string {
  return (
    byteToHex[arr[offset + 0]] +
    byteToHex[arr[offset + 1]] +
    byteToHex[arr[offset + 2]] +
    byteToHex[arr[offset + 3]] +
    "-" +
    byteToHex[arr[offset + 4]] +
    byteToHex[arr[offset + 5]] +
    "-" +
    byteToHex[arr[offset + 6]] +
    byteToHex[arr[offset + 7]] +
    "-" +
    byteToHex[arr[offset + 8]] +
    byteToHex[arr[offset + 9]] +
    "-" +
    byteToHex[arr[offset + 10]] +
    byteToHex[arr[offset + 11]] +
    byteToHex[arr[offset + 12]] +
    byteToHex[arr[offset + 13]] +
    byteToHex[arr[offset + 14]] +
    byteToHex[arr[offset + 15]]
  ).toLowerCase();
}
