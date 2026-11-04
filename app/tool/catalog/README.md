# Carga inicial de vinícolas (US32)

`vinicolas.csv` é a planilha padrão. Edite no Google Sheets/Excel e exporte
como CSV (UTF-8, separado por vírgulas) mantendo o cabeçalho.

| Coluna | Obrigatória | Formato |
|---|---|---|
| `id` | sim | slug estável, ex.: `casa-valduga`. **Nunca mude depois da 1ª carga** — é o id do documento e evita duplicar. |
| `nome`, `cidade` | sim | texto |
| `latitude`, `longitude` | sim | decimal, ex.: `-29.1756` |
| `tipos_vinho` | sim | `tinto`, `branco`, `espumante`, `rose`, separados por `;` |
| `horario` | sim | texto livre, ex.: `Seg a sáb, 9h às 17h` |
| `preco_degustacao` | sim | reais por pessoa, ex.: `85,00`; `0` = gratuita |
| `reserva_obrigatoria` | sim | `sim` ou `não` |
| `telefone`, `site` | não | texto |
| `nota` | não | 0 a 5 |
| `fonte_verificacao` | sim | `site` ou `telefone` — onde horário, preço e reserva foram confirmados |
| `data_verificacao` | sim | `dd/mm/aaaa` |

## Importar

Precisa de uma chave de *service account* do projeto Firebase
(Configurações do projeto → Contas de serviço → Gerar nova chave). Guarde-a
**fora do repositório**.

```sh
# só valida a planilha (aceita menos de 15 enquanto a coleta não termina)
dart run tool/import_wineries.dart --simular --parcial

# grava/atualiza a coleção wineries e confere o resultado
dart run tool/import_wineries.dart --projeto <id-do-projeto> --credenciais ~/winery-sa.json

# só a conferência pós-importação
dart run tool/import_wineries.dart --conferir --projeto <id-do-projeto> --credenciais ~/winery-sa.json
```

A importação recusa a planilha inteira se qualquer linha tiver problema, e a
conferência falha se alguma vinícola ficar sem horário, preço ou reserva.
