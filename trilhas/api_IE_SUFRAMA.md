# Consulta Unificada — SINTEGRA + SUFRAMA via Power Query
**Revenue Assurance GBS | Uso Interno**

---

## O que essa consulta faz

Com uma única lista de CNPJs, bate nos dois sistemas simultaneamente e retorna
tudo numa linha por empresa:

**SINTEGRA** — situação da Inscrição Estadual por UF  
**SUFRAMA** — regularidade na Zona Franca de Manaus e incentivos fiscais ativos

---

## Pré-requisito: obter a API Key

1. Acesse **sintegrapi.com.br** e crie uma conta gratuita
2. Após o login, vá em **Nossas APIs → Meu Token**
3. Copie o token — será usado no passo 4

> Mesma key para os dois sistemas. Se já tiver da consulta de IE, é só reutilizar.

---

## Passo a passo

### 1. Monte a planilha de entrada

Crie uma tabela com exatamente **duas colunas**:

| CNPJ | UF |
|---|---|
| 04.301.024/0001-31 | AM |
| 07.526.557/0001-00 | SP |

> A coluna UF é obrigatória para o SINTEGRA.  
> Para a SUFRAMA o código ignora a UF — não precisa adicionar coluna extra.  
> CNPJs sem cadastro SUFRAMA retornam os campos SF em branco, sem erro.

Selecione os dados → **Inserir → Tabela** → "Minha tabela tem cabeçalhos" → OK.  
Renomeie para **`Empresas`** (aba Design da Tabela, campo "Nome da Tabela").

---

### 2. Abra o Editor do Power Query

**Dados → Obter Dados → De Outras Fontes → Consulta em Branco**

---

### 3. Abra o editor avançado e cole o código

**Página Inicial → Editor Avançado** — apague o conteúdo e cole:

\```m
let
    ApiKey = "SUA_API_KEY_AQUI",

    Fonte = Excel.CurrentWorkbook(){[Name="Empresas"]}[Content],
    TiposCorrigidos = Table.TransformColumnTypes(Fonte, {{"CNPJ", type text}, {"UF", type text}}),

    ConsultarSintegra = (cnpj as text, uf as text) as record =>
        let
            CnpjLimpo = Text.Remove(cnpj, {".", "-", "/", " "}),
            Url = "https://api.sintegrapi.com.br/consultas/v2/sintegra/" & CnpjLimpo & "?uf=" & uf,
            Resposta = try Json.Document(
                Web.Contents(Url, [Headers = [#"x-api-key" = ApiKey, #"cache" = "0"]])
            ) otherwise null,
            IEs = if Resposta <> null and Resposta[success] = true
                  then try List.Select(Resposta[inscricoes_estaduais], each _[uf] = uf) otherwise {}
                  else {},
            IEAlvo = if List.Count(IEs) > 0 then IEs{0} else null
        in [
            ST_Razao_Social = if Resposta <> null then try Resposta[razao_social] otherwise "" else "ERRO",
            ST_IE           = if IEAlvo <> null then try IEAlvo[inscricao_estadual] otherwise "" else "",
            ST_Ativa        = if IEAlvo <> null then try Text.From(IEAlvo[ativa]) otherwise "" else "",
            ST_Situacao_PJ  = if IEAlvo <> null then try IEAlvo[situacao_pj] otherwise "" else "",
            ST_Tipo_IE      = if IEAlvo <> null then try IEAlvo[tipo_ie] otherwise "" else "",
            ST_Data_Status  = if IEAlvo <> null then try IEAlvo[data_status] otherwise "" else ""
        ],

    ConsultarSuframa = (cnpj as text) as record =>
        let
            CnpjLimpo = Text.Remove(cnpj, {".", "-", "/", " "}),
            Url = "https://api.sintegrapi.com.br/consultas/v2/suframa/" & CnpjLimpo,
            Resposta = try Json.Document(
                Web.Contents(Url, [Headers = [#"x-api-key" = ApiKey, #"cache" = "0"]])
            ) otherwise null,
            Incentivos = if Resposta <> null and Resposta[success] = true
                         then try Text.Combine(
                             List.Transform(Resposta[incentivos],
                                 each _[tributo] & " (" & _[beneficio] & ")"), " | ")
                         otherwise "" else ""
        in [
            SF_Inscricao      = if Resposta <> null then try Resposta[inscricao] otherwise "" else "",
            SF_Status         = if Resposta <> null then try Resposta[status][descricao] otherwise "" else "",
            SF_Aprovado       = if Resposta <> null then try Text.From(Resposta[aprovado]) otherwise "" else "",
            SF_Data_Aprovacao = if Resposta <> null then try Resposta[data_aprovacao] otherwise "" else "",
            SF_Incentivos     = Incentivos
        ],

    ComSintegra = Table.AddColumn(TiposCorrigidos, "ST", each ConsultarSintegra([CNPJ], [UF])),
    ExpandeST   = Table.ExpandRecordColumn(ComSintegra, "ST",
                    {"ST_Razao_Social","ST_IE","ST_Ativa","ST_Situacao_PJ","ST_Tipo_IE","ST_Data_Status"}),
    ComSuframa  = Table.AddColumn(ExpandeST, "SF", each ConsultarSuframa([CNPJ])),
    ExpandeSF   = Table.ExpandRecordColumn(ComSuframa, "SF",
                    {"SF_Inscricao","SF_Status","SF_Aprovado","SF_Data_Aprovacao","SF_Incentivos"})

in
    ExpandeSF
\```

---

### 4. Cole sua API Key

Substitua `"SUA_API_KEY_AQUI"` pela chave real, mantendo as aspas. Clique em **Concluído**.

---

### 5. Autorize a conexão web

Na primeira execução o Power Query vai pedir credenciais para cada URL da API.

- Clique em **Editar Credenciais** → selecione **Anônimo** → **Conectar**
- Repita se aparecer o aviso uma segunda vez (uma por endpoint)

---

### 6. Carregue o resultado

Clique em **Fechar e Carregar** — resultado em nova aba com todas as colunas.  
Para reprocessar: adicione linhas em `Empresas` → **Dados → Atualizar Tudo**.

---

## Colunas retornadas

### Bloco SINTEGRA — prefixo `ST_`

| Coluna | O que significa |
|---|---|
| `ST_Razao_Social` | Nome da empresa no SINTEGRA (`"ERRO"` = CNPJ não encontrado) |
| `ST_IE` | Número da Inscrição Estadual na UF informada |
| `ST_Ativa` | `TRUE` = IE ativa / `FALSE` = cancelada ou baixada |
| `ST_Situacao_PJ` | `Sem restrição` = regular / `Bloqueado como destinatário` = risco fiscal |
| `ST_Tipo_IE` | IE Normal, Substituto Tributário, Produtor Rural etc. |
| `ST_Data_Status` | Data do último status da IE |

### Bloco SUFRAMA — prefixo `SF_`

| Coluna | O que significa |
|---|---|
| `SF_Inscricao` | Número de inscrição na SUFRAMA |
| `SF_Status` | `Ativa` = regular / `Inativa` = sem benefício fiscal |
| `SF_Aprovado` | `TRUE` = cadastro aprovado pela SUFRAMA |
| `SF_Data_Aprovacao` | Data de aprovação do cadastro |
| `SF_Incentivos` | Tributos com isenção ativa — ex: `IPI (Isenção) \| ICMS (Isenção)` |

> Campos SF em branco = empresa sem cadastro SUFRAMA. Normal para empresas fora da ZFM.

---

## Problemas comuns

| Sintoma | Causa provável | Solução |
|---|---|---|
| Bloco ST inteiro com "ERRO" | API Key errada ou vencida | Verifique o token em sintegrapi.com.br |
| Aviso de privacidade ao atualizar | Nível de privacidade bloqueando | Arquivo → Opções → Configurações de Privacidade → Ignorar |
| Campos em branco para todos | Nome da tabela diferente | Confirmar que a tabela se chama exatamente `Empresas` |
| Autorização pedida duas vezes | São dois endpoints distintos | Selecionar Anônimo nas duas — comportamento normal |
| Consulta lenta | Cache desativado + lista grande | Alterar `"cache" = "0"` para `"cache" = "25"` nas duas funções |

---

*Dúvidas: acionar o responsável pela esteira.*
