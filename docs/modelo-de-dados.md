# Modelo de dados no Firestore (TT02)

Coleção única de conteúdo: `wineries/{id}`. O `id` é um slug estável
(`casa-valduga`) definido na carga inicial (US32) e nunca muda.

## `wineries/{id}`

| Campo | Tipo | Obrigatório | Observação |
|---|---|---|---|
| `name` | string | sim | |
| `city` | string | sim | |
| `address` | string | sim | Endereço exibido na ficha |
| `location` | geopoint | sim | Pin no mapa, distância e rota |
| `wineTypes` | array de string | sim | `tinto`, `branco`, `espumante`, `rose` |
| `openingHours` | map | sim | Chaves `mon` a `sun`; cada uma `{open: "09:00", close: "17:00"}` ou `null` (fechado) |
| `tastingPriceCents` | int | sim | Preço da degustação por pessoa em **centavos** (R$ 85,00 = `8500`); `0` = gratuita |
| `requiresReservation` | bool | sim | |
| `rating` | number ou null | não | Nota da equipe, 0 a 5; `null` = sem nota |
| `phone` | string ou null | não | |
| `website` | string ou null | não | |
| `photos` | array de string | não | URLs do Storage (`wineries/{id}/...`), até 5, na ordem de exibição |
| `verification` | map | não | `{source: "site" \| "telefone", verifiedAt: timestamp}` — gravado pela carga inicial |
| `updatedAt` | timestamp | sim | Atualizado em toda gravação |

Horários estruturados por dia permitem consultas como "aberta agora" (US28)
e "aberta no sábado" sem interpretar texto.

### Documento de exemplo

```json
{
  "name": "Casa Valduga",
  "city": "Bento Gonçalves",
  "address": "Via Trento, 2355 - Vale dos Vinhedos",
  "location": { "latitude": -29.1756, "longitude": -51.5577 },
  "wineTypes": ["tinto", "espumante"],
  "openingHours": {
    "mon": { "open": "09:00", "close": "17:00" },
    "tue": { "open": "09:00", "close": "17:00" },
    "wed": { "open": "09:00", "close": "17:00" },
    "thu": { "open": "09:00", "close": "17:00" },
    "fri": { "open": "09:00", "close": "17:00" },
    "sat": { "open": "09:00", "close": "17:00" },
    "sun": null
  },
  "tastingPriceCents": 8500,
  "requiresReservation": true,
  "rating": 4.7,
  "phone": "(54) 2105-3122",
  "website": "https://casavalduga.com.br",
  "photos": [],
  "updatedAt": "2026-10-26T00:00:00Z"
}
```

O app lê esse documento em `wineryFromFirestore`
(`app/lib/data/winery_repository.dart`), coberto por
`app/test/data/winery_repository_test.dart`.

## `admins/{uid}`

Um documento por administrador do catálogo (qualquer conteúdo, ex.:
`{email: "..."}`), criado **pelo console do Firebase** com o UID do usuário do
Firebase Auth. Nenhum usuário consegue criar esse documento pelo app.

## Regras de acesso

Arquivos em [`firebase/`](../firebase):

- `firestore.rules` — `wineries`: leitura pública; criar, editar e excluir só
  para admins, e só com os campos obrigatórios nos tipos acima.
  `admins`: cada usuário lê apenas o próprio registro; ninguém grava.
- `storage.rules` — `wineries/{id}/*`: leitura pública; envio e exclusão só
  para admins, JPG ou PNG de até 5 MB.

Testes das regras no emulador (precisa de Node 18+ e Java 11+):

```sh
cd firebase
npm install
npm test
```

Publicar as regras no projeto:

```sh
npx firebase deploy --only firestore:rules,storage --project <id-do-projeto>
```
