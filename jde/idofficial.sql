SELECT
    FHBNNF,    -- Número da Nota Fiscal
    FHBSER,    -- Série da Nota Fiscal
    FHMCU,     -- Centro de Custo / Filial
    FHCO,      -- Empresa
    FHFCO,     -- Empresa Fiscal
    FHSHAN,    -- Address Number do Destinatário
    FHAN8,     -- Address Number do Emitente
    FHBCGT,    -- CNPJ/CPF
    FHSHST,    -- Estado do Destinatário
    FHBCGF,    -- Inscrição Estadual
    FHISSU,    -- Data de Emissão da NF
    FHFRTH,    -- Frete
    FHLICP,    -- Chave de Acesso / DANFE
    FHSTCD,    -- Status Code
    FHUSER,    -- Usuário
    FHPID,     -- Program ID
    FHUPMJ,    -- Data da Última Atualização (Juliano)
    FHTDAY,    -- Hora da Última Atualização
    FHUSB1     -- Campo Customizado

FROM
    PRODDTA.F7601B

WHERE
    FHUPMJ BETWEEN 126001 AND 126116;
