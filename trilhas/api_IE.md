# Consulta de Situação da Inscrição Estadual — Power Query
**Revenue Assurance GBS | Uso Interno**

---

## O que essa consulta faz

Dado uma lista de CNPJs com seus respectivos estados (UF), a consulta bate automaticamente
na API do SINTEGRA e retorna, para cada empresa:

- Razão Social
- Número da Inscrição Estadual
- Se a IE está **ativa ou não**
- Situação da PJ (ex: *Sem restrição*, *Bloqueado como destinatário*)
- Tipo de IE e data do último status

---

## Pré-requisito: obter a API Key

1. Acesse **sintegrapi.com.br** e crie uma conta gratuita
2. Após o login, vá em **Nossas APIs → Meu Token**
3. Copie o token — você vai precisar dele no passo 4

---

## Passo a passo

### 1. Monte a planilha de entrada

Crie uma tabela no Excel com exatamente **duas colunas**:

| CNPJ | UF |
|---|---|
| 14.200.166/0001-37 | SP |
| 07.526.557/0001-00 | MG |

> A coluna CNPJ pode ter máscara (pontos, barra, hífen) — o código limpa sozinho.  
> A coluna UF deve ter a sigla de 2 letras maiúsculas: SP, MG, PR, RS etc.

Selecione o intervalo → **Inserir → Tabela** → marque "Minha tabela tem cabeçalhos" → OK.  
Renomeie a tabela para **`Empresas`** (aba Design da Tabela, campo "Nome da Tabela").

---

### 2. Abra o Editor do Power Query

**Dados → Obter Dados → De Outras Fontes → Consulta em Branco**

---

### 3. Abra o editor avançado

No Power Query: **Página Inicial → Editor Avançado**.  
Apague o conteúdo e cole o código abaixo:

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
            IEAlvo = if List.Count(IEs) > 0 then IEs{0} else null,
            Resultado = [
                CNPJ         = cnpj,
                UF           = uf,
                Razao_Social = if Resposta <> null then try Resposta[razao_social] otherwise "" else "ERRO",
                IE           = if IEAlvo <> null then try IEAlvo[inscricao_estadual] otherwise "" else "",
                Ativa        = if IEAlvo <> null then try Text.From(IEAlvo[ativa]) otherwise "" else "",
                Situacao_PJ  = if IEAlvo <> null then try IEAlvo[situacao_pj] otherwise "" else "",
                Tipo_IE      = if IEAlvo <> null then try IEAlvo[tipo_ie] otherwise "" else "",
                Data_Status  = if IEAlvo <> null then try IEAlvo[data_status] otherwise "" else ""
            ]
        in Resultado,

    ComResultado = Table.AddColumn(TiposCorrigidos, "Consulta", each ConsultarSintegra([CNPJ], [UF])),
    Expandido    = Table.ExpandRecordColumn(ComResultado, "Consulta",
                   {"Razao_Social","IE","Ativa","Situacao_PJ","Tipo_IE","Data_Status"})
in
    Expandido
\```

---

### 4. Cole sua API Key

Substitua `"SUA_API_KEY_AQUI"` pela chave real, mantendo as aspas. Clique em **Concluído**.

---

### 5. Autorize a conexão web

Na primeira execução o Power Query vai pedir credenciais:

- Clique em **Editar Credenciais** → selecione **Anônimo** → **Conectar**

> A autenticação real vai no cabeçalho da requisição — não precisa informar usuário/senha.

---

### 6. Carregue o resultado

Clique em **Fechar e Carregar** — resultado aparece em nova aba.  
Para reprocessar: adicione linhas na tabela `Empresas` → **Dados → Atualizar Tudo**.

---

## Interpretando o resultado

| Campo | O que significa |
|---|---|
| **Ativa** | `TRUE` = IE ativa / `FALSE` = cancelada ou baixada |
| **Situacao_PJ** | `Sem restrição` = regular / `Bloqueado como destinatário` = risco fiscal |
| **Tipo_IE** | IE Normal, Substituto Tributário, Produtor Rural etc. |
| **Razao_Social = "ERRO"** | CNPJ não encontrado ou problema de conexão |
| **IE em branco** | Empresa sem IE naquele estado (ex: prestadora de serviços) |

---

## Problemas comuns

| Sintoma | Causa provável | Solução |
|---|---|---|
| Coluna inteira com "ERRO" | API Key errada ou vencida | Verifique o token em sintegrapi.com.br |
| Aviso de privacidade ao atualizar | Nível de privacidade bloqueando | Arquivo → Opções → Configurações de Privacidade → Ignorar |
| IE em branco para todos | Nome da tabela diferente | Confirmar que a tabela se chama exatamente `Empresas` |
| Resultado vazio para um CNPJ | Empresa sem IE no estado | Normal — pode ser prestadora de serviços |
| Consulta muito lenta | Cache desativado + lista grande | Alterar `"cache" = "0"` para `"cache" = "25"` |

---

*Dúvidas: acionar o responsável pela esteira.*
