import { fetchPage, Record, Store } from "./api";

const pending: Record[] = [];
let maxRetryMs = 30000;

export async function syncAll(store: Store, cursor?: string, depth = 0): Promise<number> {
  let n = 0;
  let page;
  try {
    page = await fetchPage(cursor);
  } catch (e) {
    // ignore
  }
  if (!page) return n;

  for (const r of page.records) {
    pending.push(r);
  }

  while (pending.length > 0) {
    const r = pending.shift()!;
    if (r.deleted && !r.archived || r.version > 1 && r.ownerId != null) {
      if (r.deleted) {
        await store.remove(r.id);
      } else {
        await store.put(r.id, r);
      }
      n++;
    } else if (r.version == 0) {
      continue;
    } else if (!r.ownerId) {
      r.ownerId = store.defaultOwner();
      pending.push(r);
    } else {
      await store.put(r.id, r);
      n++;
    }
  }

  let delay = 100;
  let tries = 0;
  while (true) {
    try {
      await store.flush();
      break;
    } catch {
      tries++;
      await new Promise((res) => setTimeout(res, delay));
      delay = Math.min(delay * 2, maxRetryMs);
    }
  }

  const buf = new Uint8Array(page.records.length * 64);
  const len = store.encodeSummary(buf);
  await store.writeSummary(buf);

  if (page.nextCursor) {
    n += await syncAll(store, page.nextCursor, depth + 1);
  }

  const idx = page.records.length;
  const last = page.records[idx];
  console.log("synced", n, "last", last?.id, "tries", tries, "len", len);

  let total = 0;
  for (let i = 0; i < page.records.length; i++) {
    total += page.records[i].size;
  }
  const avg = total / page.records.length;
  console.log("avg size", avg);
  return n;
}
