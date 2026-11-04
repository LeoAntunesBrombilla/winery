# Teste de usabilidade com 5 pessoas (TT04)

Objetivo: validar o fluxo **mapa → ficha → favoritos → rota** com 5 pessoas
do perfil-alvo, confirmar as hipóteses das personas (risco R7) e as metas do
MVP. Copie este arquivo para a página do Confluence e preencha as tabelas.

## 1. Preparação

- **Build:** a versão de `development` instalada em um Android e um iPhone,
  com Firebase e chave do Maps configurados (veja `app/README.md`) e a carga
  inicial da US32 importada.
- **Perfil dos participantes:** turistas de fim de semana na Serra Gaúcha
  (Camila) ou quem já visitou e quer voltar (Eduardo). Pelo menos 2 de cada.
- **Papéis:** 1 moderador (lê o roteiro e não ajuda) e 1 observador (cronometra
  e anota).
- **Antes de cada sessão:** apagar os dados do app (favoritos e recentes vazios),
  localização ligada, Wi-Fi ou 4G normais.
- **Consentimento:** pedir autorização verbal para anotar e cronometrar; não
  gravar rosto nem dados pessoais.

## 2. Roteiro (ler igual para todos)

> "Vamos testar o app, não você. Pense em voz alta enquanto usa. Eu não vou
> poder ajudar; se travar, me diga que desistiu e seguimos."

| # | Tarefa (como ler ao participante) | Concluída quando |
|---|---|---|
| T1 | "Você vai visitar a Serra **no sábado**. Encontre uma vinícola que esteja **aberta no sábado**." | Abre a ficha de uma vinícola com horário no sábado (não "Fechado") e diz que é essa. |
| T2 | "Agora monte sua lista: **favorite 3 vinícolas** que você gostaria de visitar." | 3 vinícolas aparecem na aba Favoritos. |
| T3 | "Escolha uma das favoritas e **trace a rota** até ela." | O app de mapas abre com o destino da vinícola. |

Medir também o **tempo total** das três tarefas ("montar o roteiro").

## 3. Metas

| Métrica | Meta |
|---|---|
| Conclusão sem ajuda (por tarefa) | **≥ 80%** (4 de 5 participantes) |
| Tempo para montar o roteiro (T1 + T2 + T3) | **≤ 10 min** |

## 4. Registro das sessões

Legenda: ✅ sem ajuda · 🆘 com ajuda · ❌ não concluiu. Tempo em mm:ss.

| Participante | Perfil | Aparelho | T1 | Tempo T1 | T2 | Tempo T2 | T3 | Tempo T3 | Total | Observações |
|---|---|---|---|---|---|---|---|---|---|---|
| P1 | | | | | | | | | | |
| P2 | | | | | | | | | | |
| P3 | | | | | | | | | | |
| P4 | | | | | | | | | | |
| P5 | | | | | | | | | | |

Depois de cada sessão, perguntar:
1. "O que foi mais fácil? E o mais difícil?"
2. "Você confiaria nos horários e preços mostrados? Por quê?"
3. "De 1 a 5, quanto você usaria o app na próxima viagem?"

## 5. Resultado

| Tarefa | Sem ajuda (n/5) | % | Meta atingida? |
|---|---|---|---|
| T1 aberta no sábado | | | |
| T2 favoritar 3 | | | |
| T3 traçar rota | | | |

- Tempo médio para montar o roteiro: ____ (meta ≤ 10 min)
- Participantes dentro de 10 min: ____ de 5

## 6. Problemas encontrados → backlog

Para cada problema: quantos participantes tiveram, gravidade e o item criado no
Jira (projeto SCRUM, épico correspondente).

| Problema observado | Participantes | Gravidade (alta/média/baixa) | Correção proposta | Ticket |
|---|---|---|---|---|
| | | | | |

Gravidade: **alta** impede concluir a tarefa; **média** atrasa ou exige
tentativa e erro; **baixa** é incômodo ou sugestão. Itens de gravidade alta
entram na próxima sprint.
