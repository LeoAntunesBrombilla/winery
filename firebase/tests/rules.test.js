import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  GeoPoint,
  Timestamp,
  deleteDoc,
  doc,
  getDoc,
  setDoc,
  updateDoc,
} from 'firebase/firestore';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';

const ADMIN = 'admin-uid';
const USER = 'user-uid';

/** Documento válido, igual ao exemplo de docs/modelo-de-dados.md. */
function winery(overrides = {}) {
  const day = { open: '09:00', close: '17:00' };
  return {
    name: 'Casa Valduga',
    city: 'Bento Gonçalves',
    address: 'Via Trento, 2355 - Vale dos Vinhedos',
    location: new GeoPoint(-29.1756, -51.5577),
    wineTypes: ['tinto', 'espumante'],
    openingHours: { mon: day, tue: day, wed: day, thu: day, fri: day, sat: day, sun: null },
    tastingPriceCents: 8500,
    requiresReservation: true,
    rating: 4.7,
    phone: '(54) 2105-3122',
    website: 'https://casavalduga.com.br',
    photos: [],
    updatedAt: Timestamp.now(),
    ...overrides,
  };
}

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-winery-finder',
    firestore: { rules: readFileSync('firestore.rules', 'utf8') },
    storage: { rules: readFileSync('storage.rules', 'utf8') },
  });
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'admins', ADMIN), { email: 'admin@example.com' });
    await setDoc(doc(db, 'wineries', 'casa-valduga'), winery());
  });
});

const anonDb = () => env.unauthenticatedContext().firestore();
const userDb = () => env.authenticatedContext(USER).firestore();
const adminDb = () => env.authenticatedContext(ADMIN).firestore();

describe('wineries', () => {
  test('leitura é pública', async () => {
    await assertSucceeds(getDoc(doc(anonDb(), 'wineries', 'casa-valduga')));
  });

  test('visitante e usuário comum não gravam', async () => {
    await assertFails(setDoc(doc(anonDb(), 'wineries', 'nova'), winery()));
    await assertFails(setDoc(doc(userDb(), 'wineries', 'nova'), winery()));
    await assertFails(
      updateDoc(doc(userDb(), 'wineries', 'casa-valduga'), { name: 'X' }),
    );
    await assertFails(deleteDoc(doc(userDb(), 'wineries', 'casa-valduga')));
  });

  test('admin cadastra, edita e exclui', async () => {
    await assertSucceeds(setDoc(doc(adminDb(), 'wineries', 'nova'), winery()));
    await assertSucceeds(
      updateDoc(doc(adminDb(), 'wineries', 'nova'), {
        tastingPriceCents: 0,
        updatedAt: Timestamp.now(),
      }),
    );
    await assertSucceeds(deleteDoc(doc(adminDb(), 'wineries', 'nova')));
  });

  test('admin não grava vinícola sem campo obrigatório', async () => {
    for (const field of ['name', 'address', 'location', 'openingHours', 'tastingPriceCents', 'requiresReservation', 'updatedAt']) {
      const data = winery();
      delete data[field];
      await assertFails(setDoc(doc(adminDb(), 'wineries', 'nova'), data), field);
    }
  });

  test('admin não grava tipos ou valores inválidos', async () => {
    const invalid = [
      { name: '' },
      { location: 'Bento' },
      { tastingPriceCents: -1 },
      { tastingPriceCents: 85.5 },
      { requiresReservation: 'sim' },
      { rating: 6 },
      { openingHours: { mon: null } },
      { photos: ['1', '2', '3', '4', '5', '6'] },
    ];
    for (const overrides of invalid) {
      await assertFails(
        setDoc(doc(adminDb(), 'wineries', 'nova'), winery(overrides)),
        JSON.stringify(overrides),
      );
    }
  });

  test('vinícola sem nota é aceita', async () => {
    await assertSucceeds(
      setDoc(doc(adminDb(), 'wineries', 'nova'), winery({ rating: null })),
    );
  });
});

describe('admins', () => {
  test('cada um lê só o próprio registro e ninguém grava pelo app', async () => {
    await assertSucceeds(getDoc(doc(adminDb(), 'admins', ADMIN)));
    await assertFails(getDoc(doc(userDb(), 'admins', ADMIN)));
    await assertFails(setDoc(doc(userDb(), 'admins', USER), {}));
  });
});

describe('fotos no Storage', () => {
  const jpg = new Uint8Array([0xff, 0xd8, 0xff]);
  const path = 'wineries/casa-valduga/1.jpg';
  const storageOf = (context) => context.storage();

  test('admin envia JPG/PNG e exclui', async () => {
    const storage = storageOf(env.authenticatedContext(ADMIN));
    await assertSucceeds(uploadBytes(ref(storage, path), jpg, { contentType: 'image/jpeg' }));
    await assertSucceeds(
      uploadBytes(ref(storage, 'wineries/casa-valduga/2.png'), jpg, { contentType: 'image/png' }),
    );
    await assertSucceeds(getBytes(ref(storageOf(env.unauthenticatedContext()), path)));
    await assertSucceeds(deleteObject(ref(storage, path)));
  });

  test('usuário comum não envia nem exclui', async () => {
    const storage = storageOf(env.authenticatedContext(USER));
    await assertFails(uploadBytes(ref(storage, path), jpg, { contentType: 'image/jpeg' }));
  });

  test('recusa outros formatos e arquivos acima de 5 MB', async () => {
    const storage = storageOf(env.authenticatedContext(ADMIN));
    await assertFails(
      uploadBytes(ref(storage, 'wineries/casa-valduga/x.gif'), jpg, { contentType: 'image/gif' }),
    );
    const big = new Uint8Array(5 * 1024 * 1024 + 1);
    await assertFails(uploadBytes(ref(storage, path), big, { contentType: 'image/jpeg' }));
  });
});
